'use strict';

module.exports.demoFunction = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: 'Hello, world!',
        input: event,
      },
      null,
      2
    ),
  };
};

handler
  .use

module.exports = {
  handler
}