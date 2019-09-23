package main
import (
	"fmt"
	"path/filepath"
	"log"
	"io/ioutil"
	"net"
	"bytes"
	"strings"
	"net/http"
  "time"
)

func main() {
	files, err := filepath.Glob("/tmp/fpb/free-*.md")
	if err != nil {
		log.Fatal(err)
	}

	for _,file := range files {
		urls := extractUrls(file)
		testUrls(urls)
	}
}

func testUrls(urls []string) {
	for _,url := range urls {

		client := &http.Client{
			CheckRedirect: func(req *http.Request, via []*http.Request) error {
        // uncomment below if you want to see where it is redirecting to
				// log.Println("redirect", req.URL)
				if len(via) >= 10 {
					return http.ErrUseLastResponse
				}
				return nil
			},
      Timeout: time.Second * 20,

		}

		resp, err := client.Get(url)
    if err, ok := err.(net.Error); ok && err.Timeout() {
			fmt.Println("+ [ ] ", "999 TIMEOUT", url)
      continue
    } else if te, ok := err.(interface{ Temporary() bool}); ok {
      if te.Temporary() {
        fmt.Println("retryable", err)
      }else{
        fmt.Println("non-retryable", err)
      }
      //fmt.Println("+ [ ] ", "998 BAD_CERT", url)
      continue
		} else {
       check(err)
    }

		defer resp.Body.Close()
		if resp.StatusCode >= 300 && resp.StatusCode <= 399 {
			//fmt.Println(resp.Header.Get("Location"),url)
		} else if resp.StatusCode >= 400 {
			fmt.Println("+ [ ] ", resp.Status, url)
		}
	}
}

func extractUrls(file string) []string {
	output := make([]string, 0)
	dat, err := ioutil.ReadFile(file)
	check(err)
	//fmt.Print(string(dat))
	newline := []byte{'\n'}
	splitFile := bytes.Split(dat, newline)
	for _,line := range splitFile {
		if strings.Contains(string(line), "http") {
			//fmt.Println(string(line))
			url := strings.Split(string(line), "(")
			a := url[1]
			b := strings.Split(string(a), ")")
			c := b[0]
			if strings.Contains(c, "http") {
				output = append(output, c)
			}
		}
	}
	return output
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}
