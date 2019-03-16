function createdBy(parent, args, context) {
  return context.prisma.session({ id: parent.id }).createdBy();
}

function week(parent, args, context) {
  return context.prisma.session({ id: parent.id }).week();
}

module.exports = {
  createdBy,
  week
};
