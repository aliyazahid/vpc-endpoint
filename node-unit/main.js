const { EC2Client, DescribeImagesCommand } = require("@aws-sdk/client-ec2");

const ec2Client = new EC2Client({});

const getAMIs = async () => {
  const params = { Filters: [{ Name: "tag:solution", Values: ["abc"] }] };

  try {
    const response = await ec2Client.send(new DescribeImagesCommand(params));
    return response.Images || [];
  } catch (error) {
    console.error("Error fetching AMIs:", error);
    throw error;
  }
};

module.exports = { getAMIs };
