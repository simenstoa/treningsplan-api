const { GraphQLServer } = require("graphql-yoga");
const { prisma } = require("./generated/prisma-client");
const Mutation = require("./resolvers/Mutation");
const Query = require("./resolvers/Query");
const User = require("./resolvers/User");
const Plan = require("./resolvers/Plan");
const Phase = require("./resolvers/Phase");
const Week = require("./resolvers/Week");

const resolvers = {
  Query,
  Mutation,
  User,
  Plan,
  Phase,
  Week
};

const server = new GraphQLServer({
  typeDefs: "./src/schema.graphql",
  resolvers,
  context: request => {
    return {
      ...request,
      prisma
    };
  }
});
server.start(() => console.log(`Server is running on http://localhost:4000`));
