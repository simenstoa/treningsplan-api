"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var prisma_lib_1 = require("prisma-client-lib");
var typeDefs = require("./prisma-schema").typeDefs;

var models = [
  {
    name: "Plan",
    embedded: false
  },
  {
    name: "Phase",
    embedded: false
  },
  {
    name: "Week",
    embedded: false
  },
  {
    name: "Session",
    embedded: false
  },
  {
    name: "AdvancedSession",
    embedded: false
  },
  {
    name: "Set",
    embedded: false
  },
  {
    name: "Pause",
    embedded: false
  },
  {
    name: "PauseType",
    embedded: false
  },
  {
    name: "Intensity",
    embedded: false
  },
  {
    name: "Bout",
    embedded: false
  },
  {
    name: "IntensityType",
    embedded: false
  },
  {
    name: "User",
    embedded: false
  }
];
exports.Prisma = prisma_lib_1.makePrismaClientClass({
  typeDefs,
  models,
  endpoint: `${process.env["PRISMA_ENDPOINT"]}`,
  secret: `${process.env["PRISMA_SECRET"]}`
});
exports.prisma = new exports.Prisma();
