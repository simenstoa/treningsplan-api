function createdBy(parent, args, context) {
  return context.prisma.plan({ id: parent.id }).createdBy();
}

module.exports = {
  createdBy
};
