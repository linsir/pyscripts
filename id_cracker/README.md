## 身份证号码验证及生成。

```python
name = '邓超'
app = IDCard()
app.get_checkcode(id[:-1])
print app.get_location(id[:6])['address']
print app.has_location(id[:6])
print app.validation_id(id)
for x in app.gen_id('350626', '19870108', '0'):
    print x
print app.validation_id_net(id, name)

```
