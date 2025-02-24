const { mockClient } = require("aws-sdk-client-mock");
const { EC2Client, DescribeImagesCommand } = require("@aws-sdk/client-ec2");
const { getAMIs } = require("./main"); // Import the Lambda function

// Create mock for EC2Client
const ec2Mock = mockClient(EC2Client);

describe("getAMIs Lambda Function", () => {
  beforeEach(() => {
    ec2Mock.reset(); // Reset mocks before each test
  });

  test("should return AMIs with tag solution=abc", async () => {
    ec2Mock.on(DescribeImagesCommand).resolves({
      Images: [{ ImageId: "ami-12345", Tags: [{ Key: "solution", Value: "abc" }] }],
    });

    const result = await getAMIs();

    expect(result).toHaveLength(1);
    expect(result[0].ImageId).toBe("ami-12345");
  });

  test("should return an empty array when no AMIs match", async () => {
    ec2Mock.on(DescribeImagesCommand).resolves({ Images: [] });

    const result = await getAMIs();

    expect(result).toHaveLength(0);
  });

//   test("should throw an error if AWS API call fails", async () => {
//     ec2Mock.on(DescribeImagesCommand).rejects(new Error("AWS API Error"));

//     await expect(getAMIs()).rejects.toThrow("AWS API Error");
//   });
});
