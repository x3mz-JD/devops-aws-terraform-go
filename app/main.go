package main
// Cambio para despertar al robot de Docker 
import (
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os" // <--- Necesario para leer variables de entorno

    _ "github.com/go-sql-driver/mysql"
)

type Usuario struct {
    ID     int    `json:"id"`
    Nombre string `json:"nombre"`
    Rol    string `json:"rol"`
}

var db *sql.DB

func main() {
    // 1. CONFIGURACIÓN DINÁMICA DE LA BASE DE DATOS
    // Buscamos la variable de entorno DB_HOST (que nos pasa Docker Compose)
    dbHost := os.Getenv("DB_HOST")
    if dbHost == "" {
        dbHost = "127.0.0.1" // Si no hay variable, usamos localhost (para pruebas sin Docker)
    }

    // Construimos la cadena de conexión usando ese host
    dsn := fmt.Sprintf("root:password123@tcp(%s:3306)/mi_app_db", dbHost)

    fmt.Println("--- CONECTANDO A ---", dsn)

    // 2. CONEXIÓN
    var err error
    db, err = sql.Open("mysql", dsn)
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    // 3. ESPERAR A QUE LA BD RESPONDA (Reintentos simples)
    if err := db.Ping(); err != nil {
        // En un caso real haríamos un bucle de reintentos, 
        // pero aquí dejaremos que Docker 'restart: always' reinicie la app si falla
        log.Fatal("❌ Error conectando a la BD (Docker la reiniciará):", err)
    }
    fmt.Println("✅ ¡Conectado a MySQL!")

    // 4. SERVIDOR WEB
    http.HandleFunc("/usuarios", obtenerUsuarios)
    fmt.Println("🚀 Servidor API corriendo en el puerto 8080")
    http.ListenAndServe(":8080", nil)
}

func obtenerUsuarios(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    rows, err := db.Query("SELECT id, nombre, rol FROM usuarios")
    if err != nil {
        http.Error(w, "Error al leer base de datos", 500)
        return
    }
    defer rows.Close()

    var listaUsuarios []Usuario
    for rows.Next() {
        var u Usuario
        rows.Scan(&u.ID, &u.Nombre, &u.Rol)
        listaUsuarios = append(listaUsuarios, u)
    }

    json.NewEncoder(w).Encode(listaUsuarios)

}
