package net.morocoshi.common.loaders.fbx.expoters 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用の3Dオブジェクトデータ
	 * 
	 * @author tencho
	 */
	public class FEObject 
	{
		/**FBX文字列でコネクションを繋ぐ際に使う重要なID。他と重複してはいけない。これはFBX文字列化する際に自動でIDが割り振られる*/
		public var id:Number;
		public var name:String;
		public var visible:Boolean = true;
		public var parent:FEObject;
		public var geometry:FEGeometry;
		public var position:Vector3D = new Vector3D(0, 0, 0);
		public var rotation:Vector3D = new Vector3D(0, 0, 0);
		public var scale:Vector3D = new Vector3D(1, 1, 1);
		public var basePosition:Vector3D = new Vector3D(0, 0, 0);
		public var baseRotation:Vector3D = new Vector3D(0, 0, 0);
		public var baseScale:Vector3D = new Vector3D(1, 1, 1);
		public var rotateAnimation:FEAnimationNode;
		public var positionAnimation:FEAnimationNode;
		public var scaleAnimation:FEAnimationNode;
		public var layer:FELayer;
		public var userData:Object = { };
		
		public var rawName:String;
		static public var animationKeyList:Array = ["positionAnimation", "rotateAnimation", "scaleAnimation"];
		
		/**後でMLTの別シーンを取り込む際の識別に使用（拡張子抜きmwsファイル名に一致）*/
		public var linkage:String = "";
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function FEObject() 
		{
		}
		
		public function toFBXNode():FBXNode
		{
			//UserDataを文字列化
			var userTextList:Array = [];
			if (rawName != name) userData.rawName = rawName;
			for (var k:String in userData) 
			{
				userTextList.push(k + "=" + toStringValue(userData[k]));
			}
			var userText:String = userTextList.join("&cr;&lf;");
			if (userTextList.length) userText += "&cr;&lf;";
			
			var type:String = (!geometry)? "Null" : ((geometry is FELightGeometry)? "Light" : "Mesh");
			var node:FBXNode = new FBXNode(null, [id, "Model::" + name, type]);
			node.addValue("Version", [232]);
			var p70:Array = [
				["InheritType", "enum", "", "", 1],
				["ScalingMax", "Vector3D", "Vector", "", 0, 0, 0],
				["DefaultAttributeIndex", "int", "Integer", "", 0],
				["GeometricTranslation", "Vector3D", "Vector", "", basePosition.x, basePosition.y, basePosition.z],
				["GeometricRotation", "Vector3D", "Vector", "", baseRotation.x, baseRotation.y, baseRotation.z],
				["GeometricScaling", "Vector3D", "Vector", "", baseScale.x, baseScale.y, baseScale.z],
				["Lcl Translation", "Lcl Translation", "", "A", position.x, position.y, position.z],
				["Lcl Rotation", "Lcl Rotation", "", "A", rotation.x, rotation.y, rotation.z],
				["Lcl Scaling", "Lcl Scaling", "", "A", scale.x, scale.y, scale.z],
				["UDP3DSMAX", "KString", "", "U", userText]
			];
			if (!visible)
			{
				p70.push(["Show", "bool", "", "", int(visible)]);
			}
			FBXParser.addPropertyNode(node, p70);
			node.addValue("MultiLayer", [0]);
			node.addValue("MultiTake", [1]);
			//node.addValue("Shading", ["T"]);
			node.addValue("Culling", ["CullingOff"]);
			return node;
		}
		
		/**
		 * UserData用にデータを文字列化する
		 * @param	value
		 * @return
		 */
		private function toStringValue(value:*):String 
		{
			if (value is String)
			{
				return '&quot;' + value + '&quot;';
			}
			if (value is Number)
			{
				var str:String = Number(value).toFixed(20);
				if (str.indexOf(".") == -1) return str;
				str = str.match(/^(-?[0-9]+)\.([0-9]*?)(0*)$/).slice(1, 3).join(".");
				if (str.charAt(str.length - 1) == ".") return str.substr(0, str.length - 1);
				return str;
			}
			return String(value).split("&quot;").join('"');
		}
		
		public function getMatrix():Matrix3D
		{
			var mtx:Matrix3D = new Matrix3D();
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose.push(position);
			compose.push(rotation);
			compose.push(scale);
			mtx.recompose(compose);
			return mtx;
		}
		
		/**
		 * rawNameを繋いでアニメーション用IDを得る
		 */
		public function getAnimationID():String 
		{
			var target:FEObject = this;
			var list:Array = [];
			while (target)
			{
				list.push(target.rawName);
				target = target.parent;
			}
			list.reverse();
			return list.join("/");
		}
		
		public function clone():FEObject 
		{
			var result:FEObject = new FEObject();
			result.linkage = linkage;
			result.name = name;
			result.id = id;
			result.visible = visible;
			result.parent = parent;
			result.geometry = geometry;
			result.position = position.clone();
			result.rotation = rotation.clone();
			result.scale = scale.clone();
			result.basePosition = basePosition.clone();
			result.baseRotation = baseRotation.clone();
			result.baseScale = baseScale.clone();
			
			//%%%アニメーションは今のところ参照渡してる
			result.rotateAnimation = rotateAnimation;
			result.positionAnimation = positionAnimation;
			result.scaleAnimation = scaleAnimation;
			
			result.layer = layer;
			result.userData = { };
			for (var k:String in userData) 
			{
				result.userData[k] = userData[k];
			}
			result.rawName = rawName;//%%%ここは？
			return result;
		}
		
	}

}