package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"

	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	appsync := r.Group("/appsync")

	uhttps, err := url.Parse(os.Getenv("APPSYNC_ENDPOINT_GRAPHQL"))
	if err != nil {
		log.Fatal(err)
	}
	uwss, err := url.Parse(os.Getenv("APPSYNC_ENDPOINT_REALTIME"))
	if err != nil {
		log.Fatal(err)
	}

	appsync.Any("/graphql", gin.WrapH(&httputil.ReverseProxy{
		Director: func(req *http.Request) {
			if strings.ToLower(req.Header.Get(req.Header.Get("Connection"))) == "websocket" {
				req.URL.Scheme = "https"
				req.URL.Host = uwss.Host
				req.URL.Path = uwss.Path
				req.Host = uwss.Host

				q := req.URL.Query()
				sr := strings.NewReader(q.Get("header"))
				br := base64.NewDecoder(base64.RawURLEncoding, sr)
				var v map[string]string
				if err := json.NewDecoder(br).Decode(&v); err != nil {
					log.Println(err)
					return
				}
				v["host"] = uwss.Host
				b := bytes.NewBuffer([]byte{})
				if err := json.NewEncoder(b).Encode(v); err != nil {
					log.Println(err)
					return
				}
				q.Set("header", base64.URLEncoding.EncodeToString(b.Bytes()))
				req.URL.RawQuery = q.Encode()
				req.Header.Set("Host", uwss.Host)

			} else {
				req.URL.Scheme = uhttps.Scheme
				req.URL.Host = uhttps.Host
				req.URL.Path = uhttps.Path
				req.Host = uhttps.Host
			}

			log.Printf("%+v", req)
		},
	}))

	r.GET("/query", gin.WrapH(playground.Handler("GraphQL playground", "/appsync/graphql")))

	if os.Getenv("USE_TLS") != "" {
		if err := r.RunTLS(":8443", "localhost.pem", "localhost-key.pem"); err != nil {
			log.Fatal(err)
		}
	} else {
		if err := r.Run(":8080"); err != nil {
			log.Fatal(err)
		}
	}
}
