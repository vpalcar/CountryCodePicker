# country_code_picker

A flutter package for showing a country code selector.

## Usage

Just put the component in your application setting the onChanged callback.

```dart

@override
 Widget build(BuildContext context) => new Scaffold(
     body: Center(
       child: CountryCodePicker(
                onChanged: print,
                initialSelection: 'IT',
                iconColor: Colors.black,
                codeStyle: const TextStyle(fontWeight: FontWeight.w700),
                dialogTextStyle: const TextStyle(),
                searchStyle: const TextStyle(),
                closeIcon: const Icon(Icons.close),
                selectionIcon: const Icon(Icons.check),
                barrierColor: Colors.green,
                searchDecoration:
                    const InputDecoration(border: OutlineInputBorder()),
                flagDecoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(2.0)),
                buttonBackgroundColor: Colors.black12,
                title: const Text('COUNTRY CODES'),
              ),
     ),
 );

```