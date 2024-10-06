import { useCallback, useEffect, useState } from 'react'
import './App.css'

function App() {
  const [message, setMessage] = useState("not received")

  const handleMessage = useCallback((event: MessageEvent) => {
    // @ts-ignore
         webkit.messageHandlers.wmui.postMessage({
                 message: 'hello from handleMessage', 
             }); 
    setMessage(`received message: ${event.data}`)
  }, [])

  useEffect(() => {
    window.addEventListener("message", handleMessage)

    return () => {
        window.removeEventListener("message", handleMessage);
    }
  }, [])

  useEffect(() => {
    setInterval(() => {
    //   setMessage(window.test)
    }, 10)
  }, [])

  return (
    <>
      <div className="card">
        <p>
          message is {message}
        </p>
      </div>
    </>
  )
}

export default App
