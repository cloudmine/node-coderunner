//
// index.js
//
function doSomething(req, reply) {
  reply('Hello');
};


function somethingElse(req, reply) {
  reply({some: 'json'});
};

function getPayload(req, reply) {
  reply(req.payload);
};

function error(req, reply) {
  reply('this is an error', req.payload);
};

module.exports = {
  test1: doSomething,
  test2: somethingElse,
  getPayload: getPayload,
  error: error
};
