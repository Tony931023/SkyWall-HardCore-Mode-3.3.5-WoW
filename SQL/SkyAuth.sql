-- acore_auth
CREATE TABLE IF NOT EXISTS `hc_dead_log` (
  `username` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `level` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `killer` text COLLATE utf8mb4_general_ci,
  `date` datetime DEFAULT NULL,
  `result` text COLLATE utf8mb4_general_ci,
  `guid` text COLLATE utf8mb4_general_ci,
  `survival_time` text COLLATE utf8mb4_general_ci,
  `player_race` text COLLATE utf8mb4_general_ci,
  `player_class` text COLLATE utf8mb4_general_ci,
  `zone_name` text COLLATE utf8mb4_general_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
