rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: process.env.MONGO_HOST_1, priority: 2 },
      { _id: 1, host: process.env.MONGO_HOST_2, priority: 1 },
      { _id: 2, host: process.env.MONGO_HOST_3, arbiterOnly: true }
    ]
  }) 