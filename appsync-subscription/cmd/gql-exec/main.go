package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	graphql "github.com/hasura/go-graphql-client"
)

type apikeyTransport struct {
	APIKey string
}

func (t *apikeyTransport) RoundTrip(r *http.Request) (*http.Response, error) {
	r.Header.Set("Content-Type", "application/json")
	r.Header.Set("X-Api-Key", t.APIKey)
	return http.DefaultTransport.RoundTrip(r)
}

type AWSDateTime string

func main() {
	gqlc := graphql.NewClient(os.Getenv("APPSYNC_ENDPOINT_GRAPHQL"), &http.Client{
		Transport: &apikeyTransport{APIKey: os.Getenv("APPSYNC_API_KEY")},
	})

	gqls := graphql.NewSubscriptionClient(os.Getenv("APPSYNC_ENDPOINT_REALTIME")).
		WithConnectionParams(map[string]interface{}{
			"headers": map[string]string{"X-Api-Key": os.Getenv("APPSYNC_API_KEY")},
		})
	defer gqls.Close()

	go func() {
		log.Println("Run")
		if err := gqls.Run(); err != nil {
			log.Println(err)
		}
	}()
	time.Sleep(1 * time.Second)

	func() {
		var query struct {
			OnCreateData struct {
				ID graphql.ID
			}
		}

		log.Println("Subscribe")
		if id, err := gqls.Subscribe(&query, nil, func(raw *json.RawMessage, err error) error {
			if err != nil {
				log.Println(err)
				return err
			}

			log.Printf("%+v, %+v", raw, query)
			return nil
		}); err != nil {
			log.Println(err)
		} else {
			log.Println(id)
		}

		time.Sleep(3 * time.Second)
	}()

	ctx := context.Background()

	var respByCreateData struct {
		CreateData struct {
			ID graphql.ID
		} `graphql:"createData(value: $value, datetime: $datetime)"`
	}
	if err := gqlc.Mutate(ctx, &respByCreateData, map[string]interface{}{
		"value":    graphql.Float(1.25),
		"datetime": AWSDateTime("2021-12-05T00:00:00Z"),
	}); err != nil {
		log.Panic(err)
	}

	var respByGetData struct {
		GetData struct {
			ID       graphql.ID
			Datetime AWSDateTime
		} `graphql:"getData(id: $id)"`
	}
	if err := gqlc.Query(ctx, &respByGetData, map[string]interface{}{
		"id": respByCreateData.CreateData.ID,
	}); err != nil {
		log.Panic(err)
	}

	json.NewEncoder(os.Stdout).Encode(respByGetData)

	var respByUpdateValue struct {
		UpdateValue struct {
			ID    graphql.ID
			Value graphql.Float
		} `graphql:"updateValue(id: $id, value: $value)"`
	}
	if err := gqlc.Mutate(ctx, &respByUpdateValue, map[string]interface{}{
		"id":    respByCreateData.CreateData.ID,
		"value": graphql.Float(0.25),
	}); err != nil {
		log.Panic(err)
	}

	json.NewEncoder(os.Stdout).Encode(respByUpdateValue)
	time.Sleep(3 * time.Second)
}
