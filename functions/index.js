const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({origin: true});

const binanceApiBaseUrl = "https://data-api.binance.vision";

exports.binanceProxy = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const binanceUrl = `${binanceApiBaseUrl}${req.path}`;

      console.log(`Reenviando petición a: ${binanceUrl}`);
      console.log(`Con parámetros:`, req.query);

      const response = await axios.get(binanceUrl, {
        params: req.query,
        headers: {Accept: "application/json"},
      });

      res.status(200).send(response.data);
    } catch (error) {
      console.error("Error en el proxy de Binance:", error.message);

      if (error.response) {
        res.status(error.response.status).send(error.response.data);
      } else {
        res.status(500).send("Error interno del servidor proxy.");
      }
    }
  });
});
