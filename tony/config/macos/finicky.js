module.exports = {
  defaultBrowser: 'Firefox',
  handlers: [
    {
      match: [
        ({url}) => [
          'blockchair.com',
          'etherscan.io',
          'freetechs.slack.com',
          'help.ltfs.io',
          'tronscan.org',
          'www.getmonero.org'
        ].includes(url.host),
        ({url}) => url.host.endsWith('.tony'),
        ({url}) => url.host.startsWith('changelly.'),
        /target_link_uri=https?%3A%2F%2Fchangelly\./,
        /target_link_uri=https?%3A%2F%2F[^\/]+\.tony\//,
      ],
      browser: {
        name: 'Google Chrome',
        profile: 'Tony'
      }
    },
    {
      match: ({url}) => url.host.endsWith('.onion'),
      browser: 'Tor Browser'
    }
  ]
}
