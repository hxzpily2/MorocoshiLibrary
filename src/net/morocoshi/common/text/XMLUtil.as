package net.morocoshi.common.text 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class XMLUtil 
	{
		static public function getAttrBoolean(node:*, attr:String, def:Boolean):Boolean
		{
			if (node == undefined) return def;
			if (node is XMLList) node = node[0];
			if (!node.hasOwnProperty("@" + attr)) return def;
			if (def) node.@[attr] != "false";
			return node.@[attr] == "true";
		}
		
		static public function getAttrColor(node:*, attr:String, def:uint):uint 
		{
			if (node == undefined) return def;
			if (node is XMLList) node = node[0];
			if (!node.hasOwnProperty("@" + attr)) return def;
			return parseInt(node.@[attr], 16);
		}
		
		static public function getAttrString(node:*, attr:String, def:String):String
		{
			if (node == undefined) return def;
			if (node is XMLList) node = node[0];
			if (!node.hasOwnProperty("@" + attr)) return def;
			return String(node.@[attr]);
		}
		
		static public function getAttrNumber(node:*, attr:String, def:Number):Number
		{
			if (node == undefined) return def;
			if (node is XMLList) node = node[0];
			if (!node.hasOwnProperty("@" + attr)) return def;
			var num:Number = Number(node.@[attr]);
			if (isNaN(num)) return def;
			return num;
		}
		
		static public function getNodeNumber(node:*, def:Number):Number 
		{
			if (node == undefined) return def;
			var num:Number = Number(node);
			if (isNaN(num)) return def;
			return num;
		}
		
		static public function getNodeColor(node:*, def:uint):uint 
		{
			if (node == undefined) return def;
			return parseInt(node, 16);
		}
		
		static public function getNodeString(node:*, def:String):String 
		{
			if (node == undefined) return def;
			return String(node);
		}
		
		static public function getNodeBoolean(node:*, def:Boolean):Boolean
		{
			if (node == undefined) return def;
			if (def) node != "false";
			return node == "true";
		}
		
		/**
		 * 文字列をXML化する。コメントノードを破棄するか保持するか設定可能。
		 * @param	text	XML文字列
		 * @param	ignoreComments	コメントノードを破棄するか
		 * @return
		 */
		static public function toXML(text:String, ignoreComments:Boolean):XML 
		{
			var temp:Boolean = XML.ignoreComments;
			XML.ignoreComments = ignoreComments;
			var xml:XML = new XML(text);
			XML.ignoreComments = temp;
			return xml;
		}
		
		/**
		 * XMLを文字列化する。コメントノードを破棄するか保持するか設定可能。
		 * @param	xml	XML
		 * @param	prettyIndent	インデント空白文字数（デフォルト2）
		 * @param	ignoreComments	コメントノードを破棄するか
		 * @return
		 */
		static public function toXMLString(xml:XML, ignoreComments:Boolean, prettyPrinting:Boolean = true, prettyIndent:int = 2):String 
		{
			var tempComment:Boolean = XML.ignoreComments;
			var tempIndent:int = XML.prettyIndent;
			var tempPrinting:Boolean = XML.prettyPrinting;
			
			XML.ignoreComments = ignoreComments;
			XML.prettyPrinting = prettyPrinting;
			XML.prettyIndent = prettyIndent;
			
			var result:String = xml.toXMLString();
			
			XML.ignoreComments = tempComment;
			XML.prettyPrinting = tempPrinting;
			XML.prettyIndent = tempIndent;
			
			return result;
		}
		
	}

}