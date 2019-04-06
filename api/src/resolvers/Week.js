function createdBy(parent, args, context) {
  return context.prisma.week({ id: parent.id }).createdBy();
}

function phase(parent, args, context) {
  return context.prisma.week({ id: parent.id }).phase();
}

module.exports = {
  createdBy,
  phase
};
