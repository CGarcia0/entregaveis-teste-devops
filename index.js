require('dotenv').config()
const express = require('express')
const MongoClient = require("mongodb").MongoClient;

const app = express()
const port = 3000
app.use(express.json());

const uri = process.env.MONGO_URL;
const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

let database;
client.connect().then(() => {
    database = client.db('aval_devops');
    console.log('connected');
}).catch((e) => {
    console.error('error: ', e);
});

app.get('/', async (req, res) => {
    if (database) {
        const collection = database.collection('meus_dados');
        const tests =  await collection.find();
        const allValues = await tests.toArray();
        res.status(200).send(allValues)
    } else {
        res.status(500)
    }
})

app.post('/', async (req, res) => {
    if (database && req.body) {
        const collection = database.collection('meus_dados');
        const result = await collection.insertOne(req.body);
        res.status(200).send(result)
    } else {
        res.status(500)
    }
})


app.listen(port, () => {
  console.log(`Aapp listening at http://localhost:${port}`)
})


