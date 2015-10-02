package net.morocoshi.common.loaders.fbx.objects 
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.loaders.fbx.animation.FBXAnimationNode;
	import net.morocoshi.common.loaders.fbx.FBXConst;
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXLayer;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParseOption;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	import net.morocoshi.common.loaders.fbx.FBXScene;
	import net.morocoshi.common.loaders.fbx.geometries.FBXGeometry;
	import net.morocoshi.common.loaders.fbx.geometries.FBXMeshGeometry;
	import net.morocoshi.common.loaders.fbx.materials.FBXMaterial;
	import net.morocoshi.common.loaders.fbx.materials.FBXSurface;
	import net.morocoshi.common.math.transform.TransformUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXObject extends FBXElement
	{
		public var position:Vector3D;
		public var rotation:Vector3D;
		public var scale:Vector3D;
		
		public var geometry:FBXGeometry;
		public var geometryInstance:FBXGeometry;
		/**このオブジェクトが所属しているレイヤー*/
		public var layer:FBXLayer;
		/**自分の子のリスト*/
		public var children:Vector.<FBXObject>;
		///public var reverseX:int = 1;
		///public var reverseY:int = 1;
		///public var reverseZ:int = 1;
		public var geomMatrix:Matrix3D;
		public var userData:Object;
		
		/**M3Dにパースする時に基点をAABBの中心へずらす場合のオフセット量を一時保存する場所*/
		public var offset:Vector3D;
		private var _parent:FBXObject;
		
		private const RADIAN:Number = Math.PI / 180;
		private var matrix:Matrix3D = new Matrix3D();
		public var materialList:Vector.<FBXMaterial>;
		/**このオブジェクト以下の階層が全て空のオブジェクトかどうか*/
		public var empty:Boolean = false;
		
		public var translateAnimation:FBXAnimationNode;
		public var rotateAnimation:FBXAnimationNode;
		public var scaleAnimation:FBXAnimationNode;
		
		public function get hasUserData():Boolean
		{
			if (userData == null) return false;
			
			for (var key:String in userData)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 * @param	node
		 */
		public function FBXObject(node:FBXNode = null)
		{
			children = new Vector.<FBXObject>;
			materialList = new Vector.<FBXMaterial>;
			userData = { };
			
			super(node);
		}
		
		public function get parent():FBXObject 
		{
			return _parent;
		}
		
		public function set parent(value:FBXObject):void 
		{
			if (_parent)
			{
				var i:int = _parent.children.indexOf(this);
				if (i != -1) _parent.children.splice(i, 1);
			}
			_parent = value;
			if (_parent) _parent.children.push(this);
		}
		
		/**
		 * アニメーションが含まれているか
		 */
		public function get hasAnimation():Boolean
		{
			return Boolean(translateAnimation || rotateAnimation || scaleAnimation);
		}
		
		override public function parse(node:FBXNode):void
		{
			super.parse(node);
			param = FBXParser.parseProperties(node.Properties70);
			if (param.UDP3DSMAX) parseUserData(param.UDP3DSMAX);
			
			//オブジェクトの位置・回転・スケールを調節する
			position = new Vector3D();
			rotation = new Vector3D();
			scale = new Vector3D(1, 1, 1);
			
			if (0)
			{
				matrix = new Matrix3D();
				if (param[FBXConst.POSITION])
				{
					position.x += param[FBXConst.POSITION].x;
					position.y += param[FBXConst.POSITION].y;
					position.z += param[FBXConst.POSITION].z;
					matrix.prepend(getMatrixT(param[FBXConst.POSITION]));
				}
				
				if (param[FBXConst.PRE_ROTATION])
				{
					rotation.x += param[FBXConst.PRE_ROTATION].x * RADIAN;
					rotation.y += param[FBXConst.PRE_ROTATION].y * RADIAN;
					rotation.z += param[FBXConst.PRE_ROTATION].z * RADIAN;
					matrix.prepend(getMatrixR(param[FBXConst.PRE_ROTATION]));
				}
				if (param[FBXConst.ROTATION])
				{
					rotation.x += param[FBXConst.ROTATION].x * RADIAN;
					rotation.y += param[FBXConst.ROTATION].y * RADIAN;
					rotation.z += param[FBXConst.ROTATION].z * RADIAN;
					matrix.prepend(getMatrixR(param[FBXConst.ROTATION]));
				}
				if (param[FBXConst.POST_ROTATION])
				{
					rotation.x += param[FBXConst.POST_ROTATION].x * RADIAN;
					rotation.y += param[FBXConst.POST_ROTATION].y * RADIAN;
					rotation.z += param[FBXConst.POST_ROTATION].z * RADIAN;
					matrix.prepend(getMatrixR(param[FBXConst.POST_ROTATION]));
				}
				
				if (param[FBXConst.SCALING])
				{
					scale.x *= param[FBXConst.SCALING].x;
					scale.y *= param[FBXConst.SCALING].y;
					scale.z *= param[FBXConst.SCALING].z;
					matrix.prepend(getMatrixS(param[FBXConst.SCALING]));
				}
				
				var decompose1:Vector.<Vector3D> = matrix.decompose();
				position.copyFrom(decompose1[0]);
				rotation.copyFrom(decompose1[1]);
				scale.copyFrom(decompose1[2]);
			}
			else
			{
				matrix = new Matrix3D();
				var result:Array = [];
				
				//translate
				if (param[FBXConst.POSITION])
				{
					matrix.prepend(getMatrixT(param[FBXConst.POSITION]));
					result.push("T");
				}
				
				//rotation
				if (param[FBXConst.ROTATION_OFFSET])
				{
					matrix.prepend(getMatrixT(param[FBXConst.ROTATION_OFFSET]));
					result.push("Roff");
				}
				if (param[FBXConst.ROTATION_PIVOT])
				{
					var rotationPivot:Matrix3D = getMatrixT(param[FBXConst.ROTATION_PIVOT]);
					matrix.prepend(rotationPivot);
					result.push("Rp");
				}
				if (param[FBXConst.PRE_ROTATION])
				{
					matrix.prepend(getMatrixR(param[FBXConst.PRE_ROTATION]));
					result.push("Rpre");
				}
				if (param[FBXConst.ROTATION])
				{
					matrix.prepend(getMatrixR(param[FBXConst.ROTATION]));
					result.push("R");
				}
				if (param[FBXConst.POST_ROTATION])
				{
					matrix.prepend(getMatrixR(param[FBXConst.POST_ROTATION]));
					result.push("Rpost");
				}
				if (param[FBXConst.ROTATION_PIVOT])
				{
					rotationPivot.invert();
					matrix.prepend(rotationPivot);
					result.push("Rp-1");
				}
				
				//scale
				if (param[FBXConst.SCALING_OFFSET])
				{
					matrix.prepend(getMatrixT(param[FBXConst.SCALING_OFFSET]));
					result.push("Soff");
				}
				if (param[FBXConst.SCALING_PIVOT])
				{
					var scalingPivot:Matrix3D = getMatrixT(param[FBXConst.SCALING_PIVOT]);
					matrix.prepend(scalingPivot);
					result.push("Sp");
				}
				if (param[FBXConst.SCALING])
				{
					matrix.prepend(getMatrixS(param[FBXConst.SCALING]));
					result.push("S");
				}
				if (param[FBXConst.SCALING_PIVOT])
				{
					scalingPivot.invert();
					matrix.prepend(scalingPivot);
					result.push("Sp-1");
				}
				var decompose2:Vector.<Vector3D> = matrix.decompose();
				position.copyFrom(decompose2[0]);
				rotation.copyFrom(decompose2[1]);
				scale.copyFrom(decompose2[2]);
				//trace(name, result.join("*"));
			}
			
			geomMatrix = new Matrix3D();
			var geomScale:Vector3D = param[FBXConst.GEOM_SCALING]? param[FBXConst.GEOM_SCALING] : new Vector3D(1, 1, 1);
			var geomPosition:Vector3D = param[FBXConst.GEOM_POSITION]? param[FBXConst.GEOM_POSITION] : new Vector3D(0, 0, 0);
			var geomRotation:Vector3D = param[FBXConst.GEOM_ROTATION]? param[FBXConst.GEOM_ROTATION] : new Vector3D(0, 0, 0);
			geomRotation.scaleBy(RADIAN);
			
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose[0] = geomPosition;
			compose[1] = geomRotation;
			compose[2] = geomScale;
			geomMatrix.recompose(compose);
			/*
			reverseX = (scale.x < 0)? -1 : 1;
			reverseY = (scale.y < 0)? -1 : 1;
			reverseZ = (scale.z < 0)? -1 : 1;
			*/
		}
		
		private function getMatrixS(v:Vector3D):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose[0] = new Vector3D(0, 0, 0);//t
			compose[1] = new Vector3D(0, 0, 0);//r
			compose[2] = v;//s
			result.recompose(compose);
			return result;
		}
		
		private function getMatrixR(v:Vector3D):Matrix3D
		{
			var result:Matrix3D = new Matrix3D();
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose[0] = new Vector3D(0, 0, 0);//t
			compose[1] = new Vector3D(v.x * RADIAN, v.y * RADIAN, v.z * RADIAN);//r
			compose[2] = new Vector3D(1, 1, 1);//s
			result.recompose(compose);
			return result;
		}
		
		private function getMatrixT(v:Vector3D):Matrix3D 
		{
			var result:Matrix3D = new Matrix3D();
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose[0] = v;//t
			compose[1] = new Vector3D(0, 0, 0);//r
			compose[2] = new Vector3D(1, 1, 1);//s
			result.recompose(compose);
			return result;
		}
		
		/**
		 * userDataをパースする
		 * @param	data
		 */
		private function parseUserData(data:String):void 
		{
			data = data.split("&quot;").join("\"");
			data = data.split("&lf;").join("\n");
			data = data.split("&cr;").join("\r");
			data = data.split("&quot;").join('"');
			data = data.split("\r\n").join("\r").split("\n").join("\r");
			var list:Array = data.split("\r");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				var matchList:Array = list[i].match(/(.+)=(.*)/);
				if (!matchList) continue;
				var key:String = trim(matchList[1]);
				var value:String = trim(matchList[2]);
				//MapChannel～は除外する
				if (key.indexOf("MapChannel") == 0) continue;
				userData[key] = parseUserValue(value);
			}
		}
		
		private function parseUserValue(value:String):* 
		{
			if (value == "") return null;
			var len:int = value.length;
			if (len >= 2)
			{
				var s:String = value.charAt(0);
				var e:String = value.charAt(value.length -1);
				if ((s == '"' && e == '"') || (s == "'" && e == "'"))
				{
					return value.substr(1, len - 2);
				}
			}
			if (value == "true") return true;
			if (value == "false") return false;
			return Number(value);
		}
		
		private function trim(value:String):String 
		{
			return value.replace(/^\s+|\s+$/g, "");
		}
		
		/**
		 * スケールがマイナスだとAlternativa3Dでの表示がおかしくなるため、スケールを正にしつつ頂点を反転させる。
		 * 基点がずれていた場合は全頂点を移動させる。
		 */
		public function calculateScale(scene:FBXScene):void
		{
			//自分の反転状況をチェック（親を全て辿ってチェック）
			///var reverse:Vector3D = getTotalReverse();
			//親の反転状況をチェック（親を全て辿ってチェック）
			///var parentReverse:Vector3D = parent? parent.getTotalReverse() : new Vector3D(1, 1, 1);
			
			//%%%ここが怪しい(もう直ったぽい。また不具合が出たらここを調べる)
			//親の反転に合わせて自分の座標を反転する
			/*
			position.x *= parentReverse.x;
			position.y *= parentReverse.y;
			position.z *= parentReverse.z;
			*/
			//%%%ここまで
			
			if (geometryInstance)
			{
				//自分の反転に合わせてジオメトリを反転する
				geometry = scene.getGeometry(geometryInstance.id, geomMatrix);
				//geometry = scene.getScaledGeometry(geometryInstance.id, geomMatrix, reverse.x, reverse.y, reverse.z);
			}
			/*
			if (scale.x < 0) scale.x *= -1;
			if (scale.y < 0) scale.y *= -1;
			if (scale.z < 0) scale.z *= -1;
			*/
		}
		
		/**
		 * 親を全て辿って各軸の反転をチェックする
		 * @return
		 */
		/*
		public function getTotalReverse():Vector3D
		{
			var v:Vector3D = new Vector3D(reverseX, reverseY, reverseZ);
			var target:FBXObject = parent;
			while (target)
			{
				v.x *= target.reverseX;
				v.y *= target.reverseY;
				v.z *= target.reverseZ;
				target = target.parent;
			}
			return v;
		}
		*/
		public function getMatrix():Matrix3D
		{
			var mtx:Matrix3D = new Matrix3D();
			var compose:Vector.<Vector3D> = new Vector.<Vector3D>;
			compose[0] = position;
			compose[1] = rotation;
			compose[2] = scale;
			mtx.recompose(compose);
			return mtx;
		}
		
		public function addChild(object:FBXObject):void 
		{
			object.parent = this;
		}
		
		public function addMaterial(material:FBXMaterial):void 
		{
			materialList.push(material);
		}
		
		/**
		 * サーフェイスとマテリアルを関連付ける。
		 */
		public function updateSurface(option:FBXParseOption):void
		{
			if (!geometryInstance || !(geometryInstance is FBXMeshGeometry)) return;
			
			var extraMaterial:Object = { };
			var mg:FBXMeshGeometry = geometryInstance as FBXMeshGeometry;
			
			//if (materialList.length >= FBXMeshGeometry(geometryInstance).numSurface) return;
			
			if (materialList.length > mg.numSurface) materialList.length = mg.numSurface;
			
			for (var i:int = 0; i < mg.surfaceList.length; i++) 
			{
				if (!mg.surfaceList[i]) continue;
				var material:FBXMaterial;
				if (i < materialList.length) //%%% mg.numSurface
				{
					material = materialList[i];
					material.repeat = !option.autoMaterialRepeat;
				}
				else
				{
					var surface:FBXSurface = mg.surfaceList[i];
					var rawIndex:int = mg.rawSurfaceIndex[i];
					if (extraMaterial[i] == undefined)
					{
						var mt:FBXMaterial = extraMaterial[i] = materialList[rawIndex].clone();
						mt.repeat = surface.repeatTexture;
						materialList.push(mt);
					}
					material = extraMaterial[i];
				}
				mg.surfaceList[i].material = material;
			}
		}
		
		/**
		 * userDataのkey指定で値を取得。userDataがなかったらdefが返る
		 * @param	key
		 * @return
		 */
		public function getUserData(key:String, def:* = null):* 
		{
			if (userData == null || userData.hasOwnProperty(key) == false)
			{
				return def;
			}
			return userData[key];
		}
		
		/**
		 * オブジェクトにジオメトリを関連付ける
		 * @param	geom
		 */
		public function linkGeometry(geom:FBXGeometry):void 
		{
			geometryInstance = geom;
			//ジオメトリに自分を使っているFBXObjectを追加させる
			geom.addOwnerObject(this);
			//ignoreAutoRepeatが設定されていたらジオメトリのリピート自動判定をオフにしておく
			var meshGeom:FBXMeshGeometry = geom as FBXMeshGeometry;
			if (meshGeom && userData.ignoreAutoRepeat)
			{
				meshGeom.autoRepeatTexture = false;
			}
		}
		
		/**
		 * このObjectのワールド空間から見たMatrix3Dを取得する
		 */
		public function getGlobalMatrix():Matrix3D 
		{
			var matrix:Matrix3D = new Matrix3D();
			var target:FBXObject = this;
			while (target)
			{
				matrix.append(target.getMatrix());
				target = target.parent;
			}
			return matrix;
		}
		
		/**
		 * 祖先のvisible/showを全て辿って自分が見えているか調べる。
		 * @param	option
		 * @return
		 */
		public function checkVisible(useVisible:Boolean, useShow:Boolean):Boolean 
		{
			var target:FBXObject = this;
			while (target)
			{
				if (useVisible && !target.getUserData("visible", true))
				{
					return false;
				}
				if (useShow && !target.getUserData("show", true))
				{
					return false;
				}
				target = target.parent;
			}
			return true;
		}
		
		public function getAnimationID():String
		{
			var target:FBXObject = this;
			var list:Array = [];
			while (target)
			{
				var name:String = target.userData.rawName || target.name;
				list.push(name);
				target = target.parent;
			}
			list.reverse();
			list.shift();
			return list.join("/");
		
		}
		
		/**
		 * 自分と自分の親（祖先）を辿ってUserDataの値が一致すればtrueを返す
		 * @param	name	
		 * @param	value	
		 * @param	strict	厳格な型チェックによる比較
		 * @return
		 */
		public function ancestorUserData(name:String, value:Boolean, strict:Boolean):Boolean 
		{
			var target:FBXObject = this;
			while (target)
			{
				if (strict && target.userData[name] === value) return true;
				if (!strict && target.userData[name] == value) return true;
				target = target.parent;
			}
			return false;
		}
		
		public function attachAnimation(node:FBXAnimationNode, extra:String):void 
		{
			switch(extra)
			{
				case "Lcl Translation": translateAnimation = node; break;
				case "Lcl Rotation": rotateAnimation = node; break;
				case "Lcl Scaling": scaleAnimation = node; break;
			}
		}
		
		/**
		 * 移動、回転、スケールの各アニメーションに無駄がないかチェックし、必要ならnull化する。回転のずれも修正。返り値は有効なアニメーションが1つでもあるかどうか。
		 * @return
		 */
		public function checkAnimationValid():Boolean 
		{
			if (translateAnimation && translateAnimation.checkValid() == false) translateAnimation = null;
			if (rotateAnimation)
			{
				if (rotateAnimation.checkValid() == false) rotateAnimation = null;
				if (rotateAnimation)
				{
					rotateAnimation.checkRotationError(rotation);
				}
			}
			if (scaleAnimation && scaleAnimation.checkValid() == false) scaleAnimation = null;
			return Boolean(translateAnimation || rotateAnimation || scaleAnimation);
		}
		
		public function lookAt(target:FBXObject):void 
		{
			var matrix:Matrix3D = getMatrix();
			TransformUtil.lookAt3D(matrix, target.getGlobalMatrix().position, "-x", "+y");
			var transform:Vector.<Vector3D> = matrix.decompose();
			position.copyFrom(transform[0]);
			rotation.copyFrom(transform[1]);
			scale.copyFrom(transform[2]);
		}
		
	}

}