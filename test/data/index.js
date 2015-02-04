//
// index.js
//
function doSomething(req, reply) {
  reply('Hello')
};


function somethingElse(req, reply) {
  reply({some: 'json'})
  
};

module.exports = {
  test1: doSomething,
  test2: somethingElse
};
