package net.morocoshi.common.loaders.collada 
{
	import flash.geom.Matrix3D;
	import mx.utils.StringUtil;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ColladaParserで使うなんやかんや
	 * 
	 * @author tencho
	 */
	public class ColladaUtil 
	{
		
		public function ColladaUtil() 
		{
		}
		
		static public function deleteNameSpace(xml:XML):XML
		{
			var xmlText:String = xml.toXMLString();
			xmlText = xmlText.replace(new RegExp('xmlns[^"]*"[^"]*"', "gi"), "");
			xmlText = xmlText.replace(new RegExp('xsi[^"]*"[^"]*"', "gi"), "");
			return new XML(xmlText);
		}
		
		static public function toStringArray(value:String):Array
		{
			var result:Array = [];
			var list:Array = value.split(" ");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.push(String(list[i]));
			}
			return result;
		}
		
		static public function toNumberArray(value:String):Array
		{
			var result:Array = [];
			var list:Array = value.split(" ");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.push(Number(list[i]));
			}
			return result;
		}
		
		/**
		 * ＜source id="xxx"＞～をパースして[[0,0,0],[0,0,0]]形式で返す
		 * @param	xml
		 * @return
		 */
		static public function getSource(xml:XML):Array
		{
			var segment:int = XMLUtil.getAttrNumber(xml..accessor[0], "stride", 0);
			if (segment == 0) return null;
			if (xml.Name_array[0])
			{
				return toStringArrayList(xml.Name_array[0], segment);
			}
			if (xml.float_array[0])
			{
				return toNumberArrayList(xml.float_array[0], segment);
			}
			return null;
		}
		
		static public function toNumberArrayList(value:String, segment:int):Array 
		{
			var result:Array = [];
			var list:Array = toNumberArray(value);
			var n:int = list.length;
			for (var i:int = 0; i < n; i+= segment) 
			{
				result.push(list.slice(i, i + segment));
			}
			return result;
		}
		
		static public function toStringArrayList(value:String, segment:int):Array 
		{
			var result:Array = [];
			var list:Array = toStringArray(value);
			var n:int = list.length;
			for (var i:int = 0; i < n; i+= segment) 
			{
				result.push(list.slice(i, i + segment));
			}
			return result;
		}
		
		/**
		 * TangentとBinormalとNormalからTangent4を求める
		 * @param	tangent
		 * @param	binormal
		 * @param	normal
		 * @return
		 */
		static public function getTangent4(tangent:Array, binormal:Array, normal:Array):Array 
		{
			var crossX:Number = normal[1] * tangent[2] - normal[2] * tangent[1];
			var crossY:Number = normal[2] * tangent[0] - normal[0] * tangent[2];
			var crossZ:Number = normal[0] * tangent[1] - normal[1] * tangent[0];
			var dot:Number = crossX * binormal[0] + crossY * binormal[1] + crossZ * binormal[2];
			var b:int = dot < 0 ? -1 : 1;
			return [tangent[0], tangent[1], tangent[2], b];
		}
		
		/**
		 * [R G B]の配列をRGBカラーにする
		 * @param	xml
		 * @param	def
		 * @return
		 */
		static public function toRGB(xml:*, def:uint = 0x0):uint
		{
			if (xml == undefined) return def;
			
			var list:Array = toNumberArray(xml);
			if (list.length != 3) return def;
			
			return int(list[0] * 0xff) << 16 | int(list[1] * 0xff) << 8 | int(list[0] * 0xff);
		}
		
		/**
		 * [R G B A]の配列をARGBカラーにする
		 * @param	xml
		 * @param	def
		 * @return
		 */
		static public function toARGB(xml:*, def:uint = 0x0):uint 
		{
			if (xml == undefined) return def;
			
			var list:Array = toNumberArray(xml);
			if (list.length != 4) return def;
			
			return int(list[3] * 0xff) << 24 | int(list[0] * 0xff) << 16 | int(list[1] * 0xff) << 8 | int(list[0] * 0xff);
		}
		
		static public function ArrayToMatrix3D(a:Array):Matrix3D
		{
			return new Matrix3D(Vector.<Number>([
				a[0], a[4], a[8], a[12],
				a[1], a[5], a[9], a[13],
				a[2], a[6], a[10], a[14],
				a[3], a[7], a[11], a[15]
			]));
		}
		
		static public function toMatrix3D(xml:*):Matrix3D 
		{
			if (xml == undefined) return new Matrix3D();
			return ArrayToMatrix3D(toNumberArray(xml));
		}
		
	}

}