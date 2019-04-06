const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { APP_SECRET, getUserId } = require("../utils");

function createPlan(root, args, context) {
  const userId = getUserId(context);
  return context.prisma.createPlan({
    title: args.title,
    createdBy: { connect: { id: userId } }
  });
}

async function createPhase(root, args, context) {
  const userId = getUserId(context);

  const planFromUserExists = await context.prisma.$exists.plan({
    createdBy: { id: userId },
    id: args.planId
  });
  if (!planFromUserExists) {
    throw new Error(
      `The plan does not exist, or the logged in user does not own it (planId: ${
        args.planId
      })`
    );
  }
  return context.prisma.createPhase({
    title: args.title,
    description: args.description,
    order: args.order,
    plan: { connect: { id: args.planId } },
    createdBy: { connect: { id: userId } }
  });
}

async function createWeek(root, args, context) {
  const userId = getUserId(context);

  const phaseFromUserExists = await context.prisma.$exists.phase({
    createdBy: { id: userId },
    id: args.phaseId
  });
  if (!phaseFromUserExists) {
    throw new Error(
      `The phase does not exist, or the logged in user does not own it (phaseId: ${
        args.phaseId
      })`
    );
  }
  return context.prisma.createWeek({
    title: args.title,
    description: args.description,
    order: args.order,
    phase: { connect: { id: args.phaseId } },
    createdBy: { connect: { id: userId } }
  });
}

async function createSession(root, args, context) {
  const userId = getUserId(context);

  const weekFromUserExists = await context.prisma.$exists.week({
    createdBy: { id: userId },
    id: args.weekId
  });
  if (!weekFromUserExists) {
    throw new Error(
      `The week does not exist, or the logged in user does not own it (weekId: ${
        args.weekId
      })`
    );
  }
  return context.prisma.createSession({
    title: args.title,
    description: args.description,
    purpose: args.purpose,
    day: args.order,
    week: { connect: { id: args.weekId } },
    createdBy: { connect: { id: userId } }
  });
}

async function signup(parent, args, context, info) {
  const password = await bcrypt.hash(args.password, 10);
  const user = await context.prisma.createUser({ ...args, password });
  const token = jwt.sign({ userId: user.id }, APP_SECRET);

  return {
    token,
    user
  };
}

async function login(parent, args, context, info) {
  const user = await context.prisma.user({ email: args.email });
  if (!user) {
    throw new Error("No such user found");
  }

  const valid = await bcrypt.compare(args.password, user.password);
  if (!valid) {
    throw new Error("Invalid password");
  }

  const token = jwt.sign({ userId: user.id }, APP_SECRET);

  return {
    token,
    user
  };
}

module.exports = {
  createPlan,
  createPhase,
  createWeek,
  createSession,
  signup,
  login
};
