exports.handler = function (event, context, callback) {
  console.log("%j", { event, context });

  callback(null, {
    id: "8bc582c9-5ce2-43bb-9f8b-0512bcb229aa",
    datetime: "2021-08-25T13:34:02",
    value: 0.1,
  });
};
