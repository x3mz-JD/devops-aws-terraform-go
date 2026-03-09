FROM golang:1.22

WORKDIR /app

# Copiamos los archivos de dependencias
COPY go.mod go.sum ./
RUN go mod download

# Copiamos el código
COPY . .

# Compilamos
RUN go build -o backend-api

# Avisamos del puerto
EXPOSE 8080

# Ejecutamos
CMD ["./backend-api"]
# Actualización para el pipeline
