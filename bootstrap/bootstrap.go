package main

import "fmt"

func downloadFileStream(url string) (io.Reader, error) {
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
  out, err := os.Create(filepath)
  if err != nil  {
    return err
  }
  defer out.Close()

	downloadStream, err = downloadFileStream(url)
  defer downloadStream.Close()

  // Writer the body to file
  _, err = io.Copy(out, downloadStream)
  if err != nil  {
    return err
  }

  return nil
}

func extractTarGz(gzipStream io.Reader, rootDir string) error {
	uncompressedStream, err := gzip.NewReader(gzipStream)
	if err != nil {
			return fmt.Errorf("ExtractTarGz: NewReader failed: %v", err)
	}

	tarReader := tar.NewReader(uncompressedStream)

	for true {
			header, err := tarReader.Next()

			if err == io.EOF {
					break
			}

			if err != nil {
					return fmt.Errorf("ExtractTarGz: Next() failed: %v", err)
			}

			switch header.Typeflag {
			case tar.TypeDir:
					if err := os.Mkdir(filepath.Join(rootDir, header.Name), 0755); err != nil {
							return fmt.Errorf("ExtractTarGz: Mkdir() failed: %v", err)
					}
			case tar.TypeReg:
					outFile, err := os.Create(filepath.Join(rootDir, header.Name))
					if err != nil {
							return fmt.Errorf("ExtractTarGz: Create() failed: %v", err)
					}
					if _, err := io.Copy(outFile, tarReader); err != nil {
							return fmt.Errorf("ExtractTarGz: Copy() failed: %v", err)
					}
					outFile.Close()

			default:
					return fmt.Errorf("ExtractTarGz: uknown type: %s in %s", header.Typeflag, header.Name)
			}
	}
}

func die(err error) {
	if err != nil {
		fmt.Printf("%v", err)
		os.Exit(1)
	}
}

func main() {
	fmt.Printf("Bootstrapping!")

	homeDir, err := os.UserHomeDir()
	die(err)

	binDir := filepath.Join(homeDir, "bin")
	err = os.MkdirAll(newpath, os.ModePerm)
	die(err)

	dotfilesDir := filepath.Join(homeDir, "dotfiles")
	err = os.MkdirAll(newpath, os.ModePerm)
	die(err)

	// Download dotfiles
	sourceFile := filepath.Join(dotfilesDir, "source.tar.gz")
	stream, err = downloadFileStream("https://github.com/pj/dotfiles/archive/refs/heads/main.tar.gz")
	die(err)
	defer stream.Close()

	gzipStream(stream, sourceFile)

	// Link vimrc basic

	// Link bashrc basic

	// Install vim

	// Install kubectl

	// Install k3s

	// Install jq

	// Install yq
}
