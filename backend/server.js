const express=require("express");
const cors=require("cors");
const dontenv=require("dotenv");
const connectDB = require("./config/db");

dontenv.config();
connectDB();

const app=express();

app.use(cors());
app.use(express.json());

app.get("/api/health", (req, res) => {
	res.status(200).json({ status: "ok" });
});

app.use("/api/user", require("./routes/voter"));

app.use("/api/candidate", require("./routes/candidates"));

const PORT= process.env.PORT || 3000;
app.listen(PORT,()=> console.log(`server running on port ${PORT}`));