import React from "react";
import gql from "graphql-tag";
import { Query } from "react-apollo";

const GET_DATA_LIST = gql`
  query {
    dataList {
      id
      value
    }
  }
`;

const ON_CREATE_DATA = gql`
  subscription {
   onCreateData {
      id
    }
  }
`;

const App = () => (
  <Query query={GET_DATA_LIST}>
    {({ data, loading, subscribeToMore }) => {
      if (!data) {
        return null;
      }

      if (loading) {
        return <span>Loading ...</span>;
      }

      return (
        <Messages dataList={data.dataList} subscribeToMore={subscribeToMore} />
      );
    }}
  </Query>
);

class Messages extends React.Component {
  componentDidMount() {
    this.props.subscribeToMore({
      document: ON_CREATE_DATA,
      updateQuery: (prev, { subscriptionData }) => {
        if (!subscriptionData.data) return prev;

        return {
          dataList: [...prev.dataList, subscriptionData.data.onCreateData],
        };
      },
    });
  }

  render() {
    return (
      <ul>
        {this.props.dataList.map((message) => (
          <li key={message.id}>{message.value}</li>
        ))}
      </ul>
    );
  }
}

export default App;
