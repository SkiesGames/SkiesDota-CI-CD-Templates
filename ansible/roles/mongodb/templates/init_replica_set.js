rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: "{{ ansible_default_ipv4.address }}:27017", priority: 1 }
    ]
  }) 