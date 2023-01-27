import com.google.common.base.Charsets;
import com.google.common.base.Supplier;
import com.google.common.base.Suppliers;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.sql.*;
import java.util.NoSuchElementException;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.lang.StringBuilder;
import java.util.stream.*;

public class Main {
    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");

        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/noun", handler(() -> randomWord("nouns")));
        server.createContext("/verb", handler(() -> randomWord("verbs")));
        server.createContext("/adjective", handler(() -> randomWord("adjectives")));
        server.start();
    }

    private static String randomWord(String table) {
 		Path secretPath = Paths.get("/run/secrets/db-password");        

        String dbpassword = "";
        StringBuilder contentBuilder = new StringBuilder();
        try (Stream<String> stream = Files.lines(secretPath, StandardCharsets.UTF_8)) {
            stream.forEach(s -> contentBuilder.append(s));
            dbpassword = contentBuilder.toString();
        } catch (IOException e) {
            //handle exception
        }

        try (Connection connection = DriverManager.getConnection("jdbc:postgresql://db:5432/postgres", "postgres", dbpassword)) {
            try (Statement statement = connection.createStatement()) {
                try (ResultSet set = statement.executeQuery("SELECT word FROM " + table + " ORDER BY random() LIMIT 1")) {
                    while (set.next()) {
                        return set.getString(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("SQLException: " + e.getMessage());
            System.out.println("SQLState: " + e.getSQLState());
            System.out.println("VendorError: " + e.getErrorCode());            
        }

        throw new NoSuchElementException(table);
    }

    private static HttpHandler handler(Supplier<String> word) {
        return t -> {
            String response = "{\"word\":\"" + word.get() + "\"}";
            byte[] bytes = response.getBytes(Charsets.UTF_8);

            System.out.println(response);
            
            t.getResponseHeaders().add("content-type", "application/json; charset=utf-8");
            t.getResponseHeaders().add("cache-control", "private, no-cache, no-store, must-revalidate, max-age=0");
            t.getResponseHeaders().add("pragma", "no-cache");

            t.sendResponseHeaders(200, bytes.length);

            try (OutputStream os = t.getResponseBody()) {
                os.write(bytes);
            }
        };
    }
}
