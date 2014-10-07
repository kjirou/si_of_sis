si_of_sis [![Build Status](https://travis-ci.org/kjirou/si_of_sis.svg?branch=master)](https://travis-ci.org/kjirou/si_of_sis)
=========


## Development

### Preparation
1. Read [package.json](./package.json)
2. Read [.travis.yml](./.travis.yml)
4. Read [conf/index.coffee](./conf/index.coffee)
3. Read [env/development.coffee](./env/development.coffee)

### Installation
```
git clone git@github.com:kjirou/si_of_sis.git
cd si_of_sis
npm install
```

### Run Web Server
- 1. `mongod`
- 2. `node boot/command.js fixture --development`
- 3. `npm run dev`

### Run Tests
- 1. `mongod`
- 2. `npm test`

### Use Mongo Script
- `mongo db_name scripts/mongo/script_name.js`

### Documents
- [アプリケーション設計](./doc/application-design.md)
