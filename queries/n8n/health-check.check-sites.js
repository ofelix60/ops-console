// Generated from workflows/CSDbFHcIDKj8ic8C.json (workflow "health-check", node "Check sites")
// by scripts/extract-queries.sh. Do not edit; change the workflow and re-export.

const targets = [
    "https://api.glosshall.com/health", 
    "https://livekit.glosshall.com"
]

const results = []

// ok/fail rule: a site is "ok" only if it answered with a 2xx status AND within 3s. 
const getFailureReason = (httpCode, elapsedTime, fastEnough) => {
  const code = Number(httpCode)
  if (code < 200 || code >= 300) {
    return `HTTP: ${code}`;
  }
  if (!fastEnough) {
    return `slow: ${elapsedTime}ms`
  }
  return null
}

for (const url of targets) {
  const start = Date.now();
  try {
    const response = await this.helpers.httpRequest({
        url, 
        method:'GET', 
        returnFullResponse: true,
        timeout: 10000
    });
    const elapsedMs = Date.now() - start 
    const respondedFastEnough = elapsedMs <= 3000
    const msg = getFailureReason(response.statusCode, elapsedMs, respondedFastEnough)

    results.push({
        json: {
            target: url, 
            http_code: response.statusCode, 
            response_ms: elapsedMs,
            message: msg,
            status: msg ? 'fail' : 'ok'
        }})
  } catch (error) {    
    results.push({
        json: {
            target: url, 
            http_code: null, 
            status: 'fail',
            message: error.message,
            response_ms: Date.now() - start,
            error: error.code
        }})
  }
}

return results
