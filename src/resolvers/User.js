function plans(parent, args, context) {
  return context.prisma.user({ id: parent.id }).plans();
}

module.exports = {
  plans
};
