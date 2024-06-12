package main

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

func downloadFileStream(url string) (io.ReadCloser, error) {
	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	// Check server response
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("bad status: %s", resp.Status)
	}

	return resp.Body, nil
}

func downloadFile(filepath string, url string) (err error) {
	// Create the file
	// out, err := os.Create(filepath)

	out, err := os.OpenFile(
		filepath,
		os.O_RDWR|os.O_CREATE|os.O_TRUNC,
		0766,
	)
	if err != nil {
		return err
	}
	defer out.Close()

	downloadStream, err := downloadFileStream(url)
	if err != nil {
		return err
	}
	defer downloadStream.Close()

	// Writer the body to file
	_, err = io.Copy(out, downloadStream)
	if err != nil {
		return err
	}

	return nil
}

func extractTarGz(gzipStream io.Reader, rootDir string, removePrefix int) error {
	uncompressedStream, err := gzip.NewReader(gzipStream)
	if err != nil {
		return fmt.Errorf("ExtractTarGz: NewReader failed: %v", err)
	}

	tarReader := tar.NewReader(uncompressedStream)

	for {
		header, err := tarReader.Next()

		if err == io.EOF {
			break
		}

		if err != nil {
			return fmt.Errorf("ExtractTarGz: Next() failed: %v", err)
		}

		switch header.Typeflag {
		case tar.TypeDir:
			dirList := strings.Split(header.Name, string(filepath.Separator))
			// fmt.Println(dirList)
			if err := os.MkdirAll(filepath.Join(rootDir, filepath.Join(dirList[removePrefix:]...)), 0755); err != nil {
				return fmt.Errorf("ExtractTarGz: Mkdir() failed: %v", err)
			}
		case tar.TypeReg:
			// fmt.Println(header.Name)
			dirList := strings.Split(header.Name, string(filepath.Separator))
			// fmt.Println(dirList)
			// outFile, err := os.Create(filepath.Join(rootDir, filepath.Join(dirList[removePrefix:]...)))
			outFile, err := os.OpenFile(
				filepath.Join(rootDir, filepath.Join(dirList[removePrefix:]...)),
				os.O_RDWR|os.O_CREATE|os.O_TRUNC,
				0766,
			)
			if err != nil {
				return fmt.Errorf("ExtractTarGz: Create() failed: %v", err)
			}
			if _, err := io.Copy(outFile, tarReader); err != nil {
				return fmt.Errorf("ExtractTarGz: Copy() failed: %v", err)
			}
			outFile.Close()

		default:
			fmt.Printf("ExtractTarGz: uknown type: %s in %s", string(header.Typeflag), header.Name)
		}
	}

	return nil
}

func die(err error) {
	if err != nil {
		fmt.Printf("%v", err)
		os.Exit(1)
	}
}

func main() {
	fmt.Println("Bootstrapping!")

	homeDir, err := os.UserHomeDir()
	die(err)

	binDir := filepath.Join(homeDir, "bin")
	err = os.MkdirAll(binDir, os.ModePerm)
	die(err)

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Downloading dotfiles")
		dotfilesDir := filepath.Join(homeDir, "dotfiles")
		err = os.MkdirAll(dotfilesDir, os.ModePerm)
		die(err)

		stream, err := downloadFileStream("https://github.com/pj/dotfiles/archive/refs/heads/main.tar.gz")
		die(err)
		defer stream.Close()

		err = extractTarGz(stream, dotfilesDir, 1)
		die(err)

		// Link vimrc basic

		// Link bashrc basic

		// Install vim
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Downloading kubectl")
		err = downloadFile(
			filepath.Join(binDir, "kubectl"),
			fmt.Sprintf("https://dl.k8s.io/release/v1.30.0/bin/linux/%s/kubectl", runtime.GOARCH),
		)
		die(err)
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Downloading k9s")
		k9sStream, err := downloadFileStream(
			fmt.Sprintf("https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_%s.tar.gz", runtime.GOARCH),
		)
		die(err)
		defer k9sStream.Close()
		err = extractTarGz(k9sStream, binDir, 0)
		die(err)
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Downloading jq")
		err = downloadFile(
			filepath.Join(binDir, "jq"),
			fmt.Sprintf("https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-%s", runtime.GOARCH),
		)
		die(err)
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Downloading yq")
		err = downloadFile(
			filepath.Join(binDir, "yq"),
			fmt.Sprintf("https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_%s", runtime.GOARCH),
		)
		die(err)
	}()
	wg.Wait()
}
