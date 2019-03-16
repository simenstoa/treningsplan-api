function plans(root, args, context) {
  return context.prisma.plans();
}

function phases(root, args, context) {
  return context.prisma.phases();
}

function weeks(root, args, context) {
  return context.prisma.weeks();
}

function sessions(root, args, context) {
  return context.prisma.sessions();
}

module.exports = {
  plans,
  phases,
  weeks,
  sessions
};
