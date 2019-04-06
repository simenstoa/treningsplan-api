function createdBy(parent, args, context) {
  return context.prisma.phase({ id: parent.id }).createdBy();
}

function plan(parent, args, context) {
  return context.prisma.phase({ id: parent.id }).plan();
}

module.exports = {
  createdBy,
  plan
};
