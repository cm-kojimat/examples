import React from "react";
import ReactDOM from "react-dom";
import { ApolloProvider } from "react-apollo";
import { ApolloClient } from "apollo-client";
import { getMainDefinition } from "apollo-utilities";
import { ApolloLink, split } from "apollo-link";
import { HttpLink } from "apollo-link-http";
import { WebSocketLink } from "apollo-link-ws";
import { InMemoryCache } from "apollo-cache-inmemory";

import App from "./App";

const httpLink = new HttpLink({
  uri: process.env.REACT_APP_APPSYNC_ENDPOINT_GRAPHQL,
  headers: {
    "X-Api-Key": process.env.REACT_APP_APPSYNC_APPSYNC_API_KEY,
  },
});

const wsLink = new WebSocketLink({
  uri: process.env.REACT_APP_APPSYNC_ENDPOINT_REALTIME,
  options: {
    reconnect: true,
  },
  headers: {
    "X-Api-Key": process.env.REACT_APP_APPSYNC_APPSYNC_API_KEY,
  },
});

const terminatingLink = split(
  ({ query }) => {
    const { kind, operation } = getMainDefinition(query);
    return kind === "OperationDefinition" && operation === "subscription";
  },
  wsLink,
  httpLink
);

const link = ApolloLink.from([terminatingLink]);

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
