# 🔧 OpenAI Setup Guide

## 📋 **Prerequisites**
Before implementing any AI features, you need to set up OpenAI integration.

---

## 🚀 **Step 1: Get OpenAI API Key**

1. **Sign Up/Log In** to [OpenAI Platform](https://platform.openai.com/)
2. **Navigate** to API Keys section
3. **Create New API Key**
4. **Copy** the key (save it securely!)

---

## 🔧 **Step 2: Backend Configuration**

### Update .env File
```bash
# In axiomBackend/.env
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

### Verify OpenAI Package
Your `package.json` already includes OpenAI:
```json
"openai": "^6.15.0"
```

### Test OpenAI Connection
Create a test file to verify connection:

```javascript
// axiomBackend/test_openai.js
import 'dotenv/config';
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function testConnection() {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: "Say 'Hello OpenAI!'" }],
      max_tokens: 10,
    });

    console.log('✅ OpenAI Connection Successful!');
    console.log('Response:', response.choices[0].message.content);
  } catch (error) {
    console.error('❌ OpenAI Connection Failed:', error.message);
  }
}

testConnection();
```

Run the test:
```bash
cd axiomBackend
node test_openai.js
```

---

## 📱 **Step 3: Frontend Configuration**

### Add HTTP Package (if not already present)
Your `pubspec.yaml` should have:
```yaml
dependencies:
  http: ^1.1.2
```

### Verify Network Permissions
For Android, check `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

For iOS, check `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

## 🧪 **Step 4: Test Integration**

### Backend Test
```bash
cd axiomBackend
npm run dev
```

### Frontend Test
```bash
cd axiom
flutter run
```

---

## 📊 **Cost Management**

### OpenAI Pricing (as of 2024):
- **GPT-3.5 Turbo**: ~$0.002 per 1K tokens
- **GPT-4**: ~$0.03 per 1K tokens

### Usage Tips:
1. **Use GPT-3.5** for most AI features (cheaper, faster)
2. **Set temperature** to 0.3 for consistent results
3. **Limit response length** to control costs
4. **Implement caching** for repeated requests

---

## 🔒 **Security Best Practices**

1. **Never expose API key** in frontend code
2. **Use environment variables** for all keys
3. **Implement rate limiting** on backend
4. **Monitor usage** and set spending limits
5. **Validate AI responses** before using them

---

## 🐛 **Troubleshooting**

### Issue: "OPENAI_API_KEY not found"
**Solution**: Ensure `.env` file is in the correct directory and properly formatted

### Issue: "Invalid API key"
**Solution**: Verify the API key is correct and active

### Issue: "Rate limit exceeded"
**Solution**: Wait a few minutes or upgrade your OpenAI plan

### Issue: "Network connection failed"
**Solution**: Check internet connection and firewall settings

---

## ✅ **Verification Checklist**

- [ ] OpenAI API key obtained
- [ ] .env file configured
- [ ] Backend OpenAI package installed
- [ ] Test connection successful
- [ ] Frontend HTTP client ready
- [ ] Network permissions configured
- [ ] Cost considerations reviewed

---

## 🎯 **Ready to Start!**

Once setup is complete, you can begin implementing AI features:

1. **Start with Feature #1**: Natural Language API Creation
2. **Follow the step-by-step guide**
3. **Test each feature before proceeding**

**Let's build some AI magic!** 🚀
