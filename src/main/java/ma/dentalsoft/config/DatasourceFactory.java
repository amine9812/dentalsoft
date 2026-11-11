package ma.dentalsoft.config;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Fabrique de connexion JDBC vers la base MySQL dentalSoftDB.
 * Charge la configuration depuis un fichier externe ou les variables d'environnement (BNF-02, BNF-08).
 */
public final class DatasourceFactory {

    private static final String DEFAULT_CONFIG_FILE = "config/application.properties";
    private static final String CLASSPATH_CONFIG_FILE = "/application.properties";

    private final String url;
    private final String username;
    private final String password;
    private final String driverClassName;

    public DatasourceFactory() {
        Properties props = loadProperties();
        this.driverClassName = resolveProperty(props, "db.driver", "DB_DRIVER", "com.mysql.cj.jdbc.Driver");
        this.url = resolveProperty(
                props,
                "db.url",
                "DB_URL",
                "jdbc:mysql://localhost:3306/dentalSoftDB?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Africa/Casablanca&characterEncoding=UTF-8"
        );
        this.username = resolveProperty(props, "db.username", "DB_USERNAME", "root");
        this.password = resolveProperty(props, "db.password", "DB_PASSWORD", "");

        try {
            Class.forName(this.driverClassName);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("Pilote JDBC MySQL introuvable : " + this.driverClassName, e);
        }
    }

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(this.url, this.username, this.password);
    }

    public void executeSqlScript(Path scriptPath) throws SQLException, IOException {
        try (Connection connection = getConnection();
             BufferedReader reader = Files.newBufferedReader(scriptPath, StandardCharsets.UTF_8);
             Statement statement = connection.createStatement()) {

            StringBuilder currentStatement = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("--")) {
                    continue;
                }
                currentStatement.append(line).append('\n');
                if (trimmed.endsWith(";")) {
                    String sql = currentStatement.substring(0, currentStatement.lastIndexOf(";")).trim();
                    if (!sql.isEmpty()) {
                        statement.execute(sql);
                    }
                    currentStatement.setLength(0);
                }
            }
        }
    }

    private Properties loadProperties() {
        Properties props = new Properties();
        Path externalPath = Path.of(DEFAULT_CONFIG_FILE);
        if (Files.exists(externalPath)) {
            try (InputStream in = new FileInputStream(externalPath.toFile())) {
                props.load(new InputStreamReader(in, StandardCharsets.UTF_8));
                return props;
            } catch (IOException ignored) {
                // Repli sur le fichier du classpath
            }
        }
        try (InputStream in = DatasourceFactory.class.getResourceAsStream(CLASSPATH_CONFIG_FILE)) {
            if (in != null) {
                props.load(new InputStreamReader(in, StandardCharsets.UTF_8));
            }
        } catch (IOException ignored) {
            // Repli sur les valeurs par defaut ou les variables d'environnement
        }
        return props;
    }

    private String resolveProperty(Properties props, String key, String envKey, String defaultValue) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue.trim();
        }
        String sysValue = System.getProperty(key);
        if (sysValue != null && !sysValue.isBlank()) {
            return sysValue.trim();
        }
        String fileValue = props.getProperty(key);
        if (fileValue != null && !fileValue.isBlank()) {
            return fileValue.trim();
        }
        return defaultValue;
    }
}

