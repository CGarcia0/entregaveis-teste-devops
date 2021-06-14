## Crud de exemplo para o teste de infra


### Variáveis de ambiente

Para configuração do banco de dados deve-se setar a variável `MONGO_URL` com devido valor. Por exemplo
```
MONGO_URL=mongodb://localhost
```

Pode-se também criar um arquivo .env e colocar os valores la em vez de usar variaveis do sistema

### Projeto

Este projeto utiliza o `NodeJS v14`

Este projeto utiliza o `MongoDB 4.4`


Para instalar as dependências do projeto usar o comando:

```
npm install
```

Para rodar o projeto usar o comando:

```
npm start
```

### Endpoints

Listar objetos
```
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://localhost:3000

```

Criar objetos (cria no banco de dados o body enviado)
```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"teste":"teste1"}' \
  http://localhost:3000
  ```
