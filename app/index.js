function label() {
  return "synthetic-reference-app";
}

if (require.main === module) {
  process.stdout.write(label() + "\n");
}

module.exports = { label };
