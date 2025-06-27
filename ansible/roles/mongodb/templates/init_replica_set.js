rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: "{{ ansible_default_ipv4.address }}:27017", priority: 2 },
      { _id: 1, host: "{{ ansible_default_ipv4.address }}:27018", priority: 1 },
      { _id: 2, host: "{{ ansible_default_ipv4.address }}:27019", arbiterOnly: true }
    ]
  }) 