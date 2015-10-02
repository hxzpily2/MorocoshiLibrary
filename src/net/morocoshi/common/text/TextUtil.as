package net.morocoshi.common.text 
{
	/**
	 * 文字列処理
	 * 
	 * @author tencho
	 */
	public class TextUtil
	{
		/**
		 * 各行の先頭にインデント文字を挿入する
		 * @param	str
		 * @param	indent
		 * @return
		 */
		static public function insertIndent(str:String, indent:String = "\t"):String
		{
			str = str.split("\r").join("\r" + indent);
			str = str.split("\n").join("\n" + indent);
			return indent + str;
		}
		
		/**
		 * 全角のアルファベットを半角にする
		 * @param	text
		 * @return
		 */
		static public function toHalfString(text:String):String
		{
			var str:String = "";
			var n:int = text.length;
			var charCodes:Array = [];
			for (var i:int = 0; i < n; i++)
			{
				var c:Number = text.charCodeAt(i);
				if (c >= 65281 && c <= 65374 && c != 65340) c -= 65248;
				else if (c == 8217) c = 39;
				else if (c == 8221) c = 34;
				else if (c == 12288) c = 32;
				else if (c == 65507) c = 126;
				else if (c == 65509) c = 92;
				charCodes.push(c);
			}
			return String.fromCharCode.apply(null, charCodes);
		}
		
		/**
		 * ￥r￥nと￥rを￥nに変換する
		 * @param	text
		 */
		static public function fixNewline(text:String):String 
		{
			return text.split("\r\n").join("\r").split("\r").join("\n");
		}
		
		/**
		 * コードに直接書かれた＜xml＞テキスト＜/xml＞形式のXMLから文字列を取り出す
		 * @param	xml
		 */
		static public function getXMLCode(xml:XML):String 
		{
			return fixNewline(String(xml)).replace(/\t/g, "");
		}
		
		static public function toKata(text:String):String 
		{
			var hira:int = 12354;
			var codes:Array = [];
			var n:int = text.length;
			for (var i:int = 0; i < n; i++) 
			{
				var code:Number = text.charCodeAt(i);
				if (code >= hira && code <= hira + 81)
				{
					code += 96;
				}
				codes.push(code);
			}
			
			return String.fromCharCode.apply(null, codes);
		}
		
		static public function toHira(text:String):String 
		{
			var kata:int = 12450;
			var codes:Array = [];
			var n:int = text.length;
			for (var i:int = 0; i < n; i++) 
			{
				var code:Number = text.charCodeAt(i);
				if (code >= kata && code <= kata + 81)
				{
					code -= 96;
				}
				codes.push(code);
			}
			
			return String.fromCharCode.apply(null, codes);
		}
		
		static public function fixHTMLUnicode(text:String):String 
		{
			text = text.split("&quot;").join('"');
			text = text.split("&amp;").join("&");
			text = text.split("&lt;").join("<");
			text = text.split("&gt;").join(">");
			text = text.split("&nbsp;").join(" ");
			text = text.split("&copy;").join("©");
			var reg:RegExp = /\&#(\d+);/;
			var match:Object;
			while (match = reg.exec(text))
			{
				var t1:String = text.substr(0, match.index);
				var t2:String = text.substr(match.index + match[0].length);
				var t3:String = String.fromCharCode(match[1]);
				reg.lastIndex = (t1 + t3).length;
				text = t1 + t3 + t2;
			}
			return text;
		}
	}

}