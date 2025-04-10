export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const now = new Date().toISOString();
    const country = request.cf?.country || "Unknown";
    const email = request.headers.get("cf-access-identity-email") || "Anonymous";

    // Serve the main /protected page with inline image
    if (url.pathname === "/protected") {
      let imgTag = "<p><i>Flag not found.</i></p>";
      try {
        const object = await env.COUNTRY_FLAGS.get(`${country.toLowerCase()}.png`);
        if (object) {
          const arrayBuffer = await object.arrayBuffer();
          const base64 = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));
          imgTag = `<img src="data:image/png;base64,${base64}" alt="${country} flag" width="100"/>`;
        }
      } catch (e) {
        console.error("Image error:", e);
      }

      return new Response(`
        <html>
          <body>
            <h1>${email} authenticated at ${now} from 
              <a href="/protected/${country}.png">${country}</a>
            </h1>
          </body>
        </html>
      `, {
        headers: { "content-type": "text/html" }
      });
    }

    // Serve raw image on /protected/XX.png
    const match = url.pathname.match(/^\/protected\/([a-z]{2})\.png$/i);
    if (match) {
      const countryCode = match[1].toLowerCase();
      const object = await env.COUNTRY_FLAGS.get(`${countryCode}.png`);
      if (!object) {
        return new Response("Flag not found", { status: 404 });
      }
      return new Response(object.body, {
        headers: { "content-type": "image/png" }
      });
    }

    return new Response("Not Found", { status: 404 });
  }
}
