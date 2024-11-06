import { gunzipSync } from "zlib";
import axios from "axios";

// Lambda handler function
export const handler = async (event) => {
  try {
    // Decode and decompress the CloudWatch logs
    const compressedPayload = Buffer.from(event.awslogs.data, "base64");
    const payload = gunzipSync(compressedPayload).toString("utf-8");
    const logEvent = JSON.parse(payload);

    // Format logs for Loki
    const entries = logEvent.logEvents.map((log) => {
      return [
        `${log.timestamp * 1000000}`, // Convert milliseconds to nanoseconds
        log.message,
      ];
    });

    // Prepare the data to send to Loki
    const lokiUrl = process.env.LOKI_URL; // Your Loki URL from environment variables
    const data = {
      streams: [
        {
          stream: {
            log_group: logEvent.logGroup,
            log_stream: logEvent.logStream,
          },
          values: entries,
        },
      ],
    };

    // Send logs to Loki using Axios
    const response = await axios.post(lokiUrl, data, {
      headers: { "Content-Type": "application/json" },
    });

    console.log("Response from Loki:", response.status, response.statusText);
  } catch (error) {
    console.error("Error forwarding logs to Loki:", error);
  }
};
