# Asserest YAML script documentation

This file will guided you to write a proper YAML configuration file.

## Layout

|Name|Type|Description|Mandatory|Note|
|:---:|:---:|:----|:---:|:----|
|<sub><sup>(N/A)</sup></sub>|`Array`|Containers of all URL's assertion|&check;||

## URL assertion object

These properties forms onne of the items of the array.

### Shared properties

|Name|Type|Description|Mandatory|Note|
|:---:|:---:|:----|:---:|:----|
|`url`|`String`|URL address of assertion|&check;|Currently support these schemes:<br/><ul><li>http</li><li>https</li><li>ftp</li>|
|`accessible`|`Boolean`|Expect this URL can be surf in current network|&check;||
|`timeout`|`Integer`|Determine the preiod of response in seconds and assume as inaccessible if still no response.||Default is 10 seconds and only accept multiple of 5 between 10 to 120.|
|`try_count`|`Integer`|Count of testing if URL is expected to accessible|&check; (Only for `accessible` set as `true`)|**DO NOT** define this property when `accessible` set as `false`|

### HTTP(S) exclusive properties

|Name|Type|Description|Mandatory|Note|
|:---:|:---:|:----|:---:|:----|
|`method`|`String`|HTTP request method|&check;|Only allow these values:<ul><li>`DELETE`</li><li>`GET`</li><li>`HEAD`</li><li>`PATCH`</li><li>`POST`</li><li>`PUT`</li></ul>|
|`header`|`Object`|Header of HTTP request||It suppoes is both string key-value object.|
|`body`|`Object`, `Array` or `String`|Body content of HTTP request|&check; (except `GET` and `HEAD` method)|Apply `Object` or `Array` object will be assume as JSON format.|

### FTP exclusive properties

|Name|Type|Description|Mandatory|Note|
|:---:|:---:|:----|:---:|:----|
|`username`|`String`|Username when accessing FTP server||Default as `anonymous` if omit this property.|
|`password`|`String`|Password of corresponded username|||
|`security`|`String`|Specify which FTP security is used|&check;|Only allow these value:<ul><li>`FTP` (No security)</li><li>`FTPS`</li><li>`FTPES`</li></ul>Uses `FTP` first if cannot confirm which security is used.|
