import { IoTHandler } from "aws-lambda";
import { AWSAppSyncClient, AUTH_TYPE } from "aws-appsync";
import AWS from "aws-sdk";
import gql from "graphql-tag";
import "isomorphic-fetch";

const config = {
  url: process.env.APPSYNC_ENDPOINT_GRAPHQL!,
  region: process.env.AWS_REGION!,
  auth: {
    type: AUTH_TYPE.API_KEY,
    apiKey: process.env.APPSYNC_API_KEY!,
  },
  disableOffline: true,
};

const client = new AWSAppSyncClient(config);

export const handler: IoTHandler = async function (event, context, callback) {
  console.log("%j", { event, context });

  await client.mutate({
    mutation: gql`
      mutation Insert($value: Float!, $datetime: AWSDateTime!) {
        createData(value: $value, datetime: $datetime) {
          id
        }
      }
    `,
    variables: {
      value: 3.5,
      datetime: new Date().toISOString(),
    },
  });
};
