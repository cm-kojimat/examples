import React from "react";
import ReactDOM from "react-dom";
import { ApolloProvider } from "react-apollo";
import { createAuthLink } from "aws-appsync-auth-link";
import { createSubscriptionHandshakeLink } from "aws-appsync-subscription-link";
import { ApolloClient, InMemoryCache, ApolloLink } from "@apollo/client/core";
import App from "./App";
import {
  API_KEY,
  REGION,
  ENDPOINT_GRAPHQL,
  ENDPOINT_REALTIME,
} from "./aws-exports";

const auth = {
  type: "API_KEY",
  apiKey: API_KEY,
};

const link = ApolloLink.from([
  createAuthLink({ url: ENDPOINT_GRAPHQL, region: REGION, auth }),
  createSubscriptionHandshakeLink({
    url: ENDPOINT_GRAPHQL,
    region: REGION,
    auth,
  }),
]);

const cache = new InMemoryCache();

const client = new ApolloClient({
  link,
  cache,
});

ReactDOM.render(
  <ApolloProvider client={client}>
    <App />
  </ApolloProvider>,
  document.getElementById("root")
);
