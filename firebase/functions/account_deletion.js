function bearerToken(request) {
  const header = request.get("Authorization") || "";
  return header.startsWith("Bearer ") ? header.slice(7).trim() : "";
}

async function collectOwnedDocuments(firestore, userRef, uid) {
  const queries = [
    firestore.collection("service").where("owner", "==", userRef),
    firestore.collection("records").where("client", "==", userRef),
    firestore.collection("records").where("master", "==", userRef),
    firestore.collection("chats").where("participantIds", "array-contains", uid),
    firestore.collection("notifications").where("user", "==", userRef),
    firestore.collection("reports").where("reporter", "==", userRef),
    firestore.collection("reports").where("reportedUser", "==", userRef),
  ];
  const snapshots = await Promise.all(queries.map((query) => query.get()));
  const documents = new Map();
  for (const snapshot of snapshots) {
    for (const document of snapshot.docs) {
      documents.set(document.ref.path, document.ref);
    }
  }
  return [...documents.values()];
}

function createDeleteAccountHandler({admin}) {
  return async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.set("Access-Control-Allow-Methods", "POST, OPTIONS");

    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const token = bearerToken(request);
      if (!token) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }

      const decoded = await admin.auth().verifyIdToken(token);
      const uid = decoded.uid;
      const firestore = admin.firestore();
      const userRef = firestore.collection("user").doc(uid);
      const documents = await collectOwnedDocuments(firestore, userRef, uid);

      for (const documentRef of documents) {
        await firestore.recursiveDelete(documentRef);
      }
      await firestore.recursiveDelete(userRef);

      try {
        await admin.storage().bucket().deleteFiles({prefix: `users/${uid}/`});
      } catch (error) {
        console.error("Account storage cleanup failed", {uid, error});
      }

      await admin.auth().deleteUser(uid);
      response.status(200).json({ok: true});
    } catch (error) {
      console.error("deleteAccount failed", error);
      response.status(500).json({
        error: "Account deletion failed",
        details: error && error.message ? error.message : String(error),
      });
    }
  };
}

module.exports = {bearerToken, collectOwnedDocuments, createDeleteAccountHandler};
