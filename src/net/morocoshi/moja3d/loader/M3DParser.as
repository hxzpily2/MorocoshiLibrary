package net.morocoshi.moja3d.loader 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.morocoshi.common.data.ByteArrayUtil;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	import net.morocoshi.common.loaders.tfp.TFPHolder;
	import net.morocoshi.common.loaders.tfp.TFPLoader;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.animation.AnimationCurveNode;
	import net.morocoshi.moja3d.animation.AnimationCurveTrack;
	import net.morocoshi.moja3d.animation.AnimationMaterialNode;
	import net.morocoshi.moja3d.animation.AnimationMatrixTrack;
	import net.morocoshi.moja3d.animation.AnimationPlayer;
	import net.morocoshi.moja3d.animation.CurveKey;
	import net.morocoshi.moja3d.animation.KeyframeAnimation;
	import net.morocoshi.moja3d.animation.MotionData;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.animation.M3DAnimation;
	import net.morocoshi.moja3d.loader.animation.M3DCurveTrack;
	import net.morocoshi.moja3d.loader.animation.M3DKeyframe;
	import net.morocoshi.moja3d.loader.animation.M3DMatrixTrack;
	import net.morocoshi.moja3d.loader.animation.M3DTrackUV;
	import net.morocoshi.moja3d.loader.animation.M3DTrackXYZ;
	import net.morocoshi.moja3d.loader.geometries.M3DCombinedGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DLineGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DLineSegment;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DSkinGeometry;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DBillboard;
	import net.morocoshi.moja3d.loader.objects.M3DBone;
	import net.morocoshi.moja3d.loader.objects.M3DCamera;
	import net.morocoshi.moja3d.loader.objects.M3DLight;
	import net.morocoshi.moja3d.loader.objects.M3DLine;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.objects.M3DSkin;
	import net.morocoshi.moja3d.loader.objects.M3DSkinContainer;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.materials.ParserMaterial;
	import net.morocoshi.moja3d.objects.AmbientLight;
	import net.morocoshi.moja3d.objects.Bone;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.DirectionalLight;
	import net.morocoshi.moja3d.objects.Light3D;
	import net.morocoshi.moja3d.objects.Line3D;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.objects.Skin;
	import net.morocoshi.moja3d.objects.SkinContainer;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.CombinedGeometry;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.LineGeometry;
	import net.morocoshi.moja3d.resources.LineSegment;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.ResourcePack;
	import net.morocoshi.moja3d.resources.SkinGeometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * M3DデータをパースしてMoja3Dオブジェクトを生成する
	 * 
	 * @author tencho
	 */
	public class M3DParser extends EventDispatcher
	{
		/**
		 * 現時点でのM3Dバージョン。
		 * M3Dデータのバージョンがこの数値に満たないとパース時にエラーがでます。
		 * パースに必須なパラメータが増えたり、データ構成が変わった時等にこの数値を上げます。
		 * 最新のM3Dエクスポータはこの数値をM3Dデータのバージョンに設定するので
		 * この数値を上げたら必ずM3Dエクスポータをパブリッシュして更新してください。
		 */
		static public const VERSION:Number = 1;
		
		public var animationPlayer:AnimationPlayer;
		public var keyAnimations:Vector.<KeyframeAnimation>;
		/**
		 * ベジェ曲線カーブを分割する際の間隔を秒単位で指定。分割数を決める際の参考値なので、必ずしもこの間隔になるわけではない。
		 */
		public var bezierCurveInterval:Number = 1.0 / 15;
		/**
		 * 階層構造を保ったObject3Dが格納されている
		 */
		public var hierarchy:Vector.<Object3D>;
		/**
		 * 階層を無視した全てのObject3Dのリスト
		 */
		public var objects:Vector.<Object3D>;
		/**
		 * 全てのCamera3Dのリスト
		 */
		public var cameras:Vector.<Camera3D>;
		/**
		 * 全てのマテリアルのリスト
		 */
		public var materials:Vector.<ParserMaterial>;
		/**
		 * 全てのジオメトリのリスト
		 */
		public var geometries:Vector.<Geometry>;
		/**
		 * M3Dをモーションデータとして書き出していた場合にアクセス可能
		 */
		public var motion:MotionData;
		/**
		 * 画像リソースのセット
		 */
		public var resourcePack:ResourcePack;
		
		private var _userData:Dictionary;
		private var includeTo:Object3D;
		
		private var materialA3DLink:Dictionary;
		private var objectM3DLink:Dictionary;
		private var materialM3DLink:Dictionary;
		private var geometryA3DLink:Object;
		private var geometryM3DLink:Object;
		
		private var _hasModel:Boolean;
		
		//モーションデータのみパースする場合内部でtrueにする
		private var forMotionData:Boolean;
		
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function M3DParser() 
		{
			forMotionData = false;
			animationPlayer = new AnimationPlayer();
		}
		
		/**
		 * 全てのリソースをdispose()し、画像データを破棄し、すべての参照をnullにする
		 */
		public function clear(force:Boolean = false):void
		{
			var material:ParserMaterial;
			var resource:Resource;
			var object:Object3D;
			var geom:Geometry;
			var animation:KeyframeAnimation;
			
			if (motion)
			{
				motion.clear();
			}
			
			if (resourcePack)
			{
				resourcePack.dispose();
			}
			
			if (materials)
			{
				for each (material in materials) 
				{
					material.clear(force);
				}
			}
			
			if (geometries)
			{
				for each(geom in geometries)
				{
					if (force || geom.autoDispose)
					{
						geom.clear();
					}
				}
			}
			
			if (objects)
			{
				for each (object in objects) 
				{
					object.clear(false, force);
				}
			}
			
			if (keyAnimations)
			{
				for each(animation in keyAnimations)
				{
					animation.clear();
				}
			}
			
			if (animationPlayer)
			{
				animationPlayer.clear();
			}
			
			animation = null;
			object = null;
			material = null;
			geom = null;
			
			objects = null;
			geometries = null;
			materials = null;
			resourcePack = null;
			animationPlayer = null;
			keyAnimations = null;
			_userData = null;
			includeTo = null;
			motion = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  情報取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Object3D指定でUserDataを取得
		 * @param	obj
		 * @return
		 */
		public function getUserData(obj:Object3D):Object
		{
			return _userData[obj] || null;
		}
		
		/**
		 * 
		 * @param	object
		 * @param	key
		 * @param	value
		 * @return
		 */
		public function equalAncestorUserData(object:Object3D, key:String, value:*):Boolean
		{
			var target:Object3D = object;
			while (target)
			{
				var user:Object = _userData[target];
				if (!user) return false;
				if (user[key] === value) return true;
				target = target.parent;
			}
			return false;
		}
		
		/**
		 * Object3D指定でM3DObjectを取得
		 * @param	obj
		 * @return
		 */
		public function getM3DByObject3D(obj:Object3D):M3DObject
		{
			return objectM3DLink[obj];
		}
		
		public function getM3DByMaterial(material:Material):M3DMaterial 
		{
			return materialM3DLink[material];
		}
		
		public function getObjectByName(name:String):Object3D 
		{
			for each(var object:Object3D in objects)
			{
				if (object.name == name) return object;
			}
			return null;
		}
		
		/**
		 * アニメーションIDでObject3Dを取得する
		 * @param	animationID
		 * @return
		 */
		public function getObjectByAnimationID(animationID:String):Object3D 
		{
			for each(var object:Object3D in objects)
			{
				if (object.animationID == animationID) return object;
			}
			return null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  パース
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	data
		 * @param	includeTo
		 * @return
		 */
		public function parse(data:ByteArray, includeTo:Object3D = null):M3DParser
		{
			this.includeTo = includeTo;
			
			init();
			
			if (data == null)
			{
				dispatchError("引数に渡されたByteArrayがnullです！");
				return this;
			}
			
			var holder:TFPHolder = new TFPHolder();
			var loader:TFPLoader = new TFPLoader(holder);
			loader.cacheEnabled = false;
			loader.addEventListener(TFPErrorEvent.INSTANTIATION_ERROR, tfpLoader_errorHandler);
			loader.addEventListener(TFPErrorEvent.LOAD_ERROR, tfpLoader_errorHandler);
			loader.addEventListener(Event.COMPLETE, tfpLoader_completeHandler);
			loader.loadFromByteArray(data);
			
			return this;
		}
		
		/**
		 * MotionDataをパースする
		 * @param	data	M3Dデータ
		 * @param	bezierCurveInterval	ベジェ曲線カーブを分割する際の間隔を秒単位で指定。分割数を決める際の参考値なので、必ずしもこの間隔になるわけではない。
		 * @return
		 */
		static public function parseMotion(data:ByteArray, bezierCurveInterval:Number):MotionData 
		{
			var parser:M3DParser = new M3DParser();
			parser.forMotionData = true;
			parser.bezierCurveInterval = bezierCurveInterval;
			parser.parse(data);
			return parser.motion;
		}
		
		private function init():void 
		{
			registClasses();
			
			hierarchy = new Vector.<Object3D>;
			objects = new Vector.<Object3D>;
			cameras = new Vector.<Camera3D>;
			materials = new Vector.<ParserMaterial>;
			geometries = new Vector.<Geometry>;
			keyAnimations = new Vector.<KeyframeAnimation>;
		}
		
		private function tfpLoader_errorHandler(e:TFPErrorEvent):void 
		{
			dispatchError(e.text);
		}
		
		private function tfpLoader_completeHandler(e:Event):void 
		{
			var i:int;
			var n:int;
			
			var loader:TFPLoader = e.currentTarget as TFPLoader;
			loader.removeEventListener(Event.COMPLETE, tfpLoader_completeHandler);
			var info:M3DInfo = loader.holder.getByteArray("/info.dat").readObject() as M3DInfo;
			
			_hasModel = info.hasModel;
			
			resourcePack = null;
			//画像があったら
			if (info.hasImage)
			{
				resourcePack = new ResourcePack();
				for (var assetPath:String in loader.holder.asset)
				{
					if (assetPath.substr(0, 7) == "/image/")
					{
						var assetData:* = loader.holder.getAsset(assetPath);
						var assetName:String = assetPath.substr(7);
						resourcePack.register(assetName, assetData, true);
					}
				}
			}
			//画像のみだったらここで終了
			if (info.hasModel == false && info.hasAnimation == false)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			//データ解凍
			var data:ByteArray = ByteArrayUtil.clone(loader.holder.getByteArray("/scene.dat"));
			data.uncompress();
			parseM3DScene(data.readObject());
		}
		
		moja3d function parseScene(scene:M3DScene, includeTo:Object3D = null):void
		{
			init();
			this.includeTo = includeTo;
			
			resourcePack = null;
			_hasModel = true;
			parseM3DScene(scene);
		}
		
		private function parseM3DScene(scene:M3DScene):void
		{
			//this.scene = scene;
			
			var i:int;
			var n:int;
			
			//バージョンチェック
			var ver:Number = scene.version || 0;
			if (ver < VERSION)
			{
				throw new Error("M3Dのモデルのバージョンが低いためパースできません。");
			}
			
			//色々準備
			///var animatedObjectLink:Dictionary = new Dictionary();
			var objectA3DLink:Dictionary = new Dictionary();
			objectM3DLink = new Dictionary();
			materialM3DLink = new Dictionary();
			materialA3DLink = new Dictionary();
			geometryA3DLink = { };
			geometryM3DLink = scene.getGeometryLink();
			
			var objectM3D:M3DObject;
			var objectA3D:Object3D;
			
			//Geometryパース
			var geomM3D:M3DGeometry;
			var geomA3D:Geometry;
			var combineRequest:Vector.<M3DCombinedGeometry> = new Vector.<M3DCombinedGeometry>;
			
			//通常モデルデータの場合
			if (forMotionData == false)
			{
				//単体のジオメトリをパース
				n = scene.geometryList.length;
				for (i = 0; i < n; i++) 
				{
					geomM3D = scene.geometryList[i];
					//もしジオメトリが集合体だった場合
					if (geomM3D is M3DCombinedGeometry)
					{
						combineRequest.push(geomM3D);
						continue;
					}
					geomA3D = toGeometry(geomM3D as M3DMeshGeometry);
					//エラーが出ていたら処理停止
					if (geomA3D == null) return;
					geometryA3DLink[geomM3D.id] = geomA3D;
					geometries.push(geomA3D);
				}
				
				//Materialパース
				n = scene.materialList.length;
				for (i = 0; i < n; i++) 
				{
					var materialM3D:M3DMaterial = scene.materialList[i];
					
					//アニメーション
					var materialAnimation:KeyframeAnimation;
					if (materialM3D.animation)
					{
						materialAnimation = toKeyAnimation(materialM3D.animation);
						materialAnimation.initMaterialShader();
						keyAnimations.push(materialAnimation);
						animationPlayer.keyAnimations.push(materialAnimation);
					}
					
					var materialA3D:ParserMaterial = new ParserMaterial(materialM3D, materialAnimation);
					materialA3DLink[materialM3D.id] = materialA3D;
					materialM3DLink[materialA3D] = materialM3D;
					materials.push(materialA3D);
				}
				
				//集合体のジオメトリをパース
				n = combineRequest.length;
				for (i = 0; i < n; i++) 
				{
					geomM3D = combineRequest[i];
					geomA3D = toCombinedGeometry(geomM3D as M3DCombinedGeometry);
					geometryA3DLink[geomM3D.id] = geomA3D;
					geometries.push(geomA3D);
				}
				
				//Objectパース
				n = scene.objectList.length;
				for (i = 0; i < n; i++) 
				{
					objectM3D = scene.objectList[i];
					objectA3D = toObject3D(objectM3D);
					//エラーが出ていたら処理停止
					if (objectA3D == null) return;
					
					objectA3D.calculateBounds();
					objectM3DLink[objectA3D] = objectM3D;
					objectA3DLink[objectM3D.id] = objectA3D;
					objects.push(objectA3D);
					
					if (objectA3D is Camera3D)
					{
						cameras.push(objectA3D as Camera3D);
					}
					
					//アニメーション
					if (objectM3D.animation)
					{
						var anm:KeyframeAnimation = toKeyAnimation(objectM3D.animation);
						anm.linkObject(objectA3D);
						///animatedObjectLink[anm] = objectA3D;
						keyAnimations.push(anm);
						animationPlayer.keyAnimations.push(anm);
					}
				}
				
				animationPlayer.checkTime();
				
				//親子リンク
				for (i = 0; i < n; i++) 
				{
					objectM3D = scene.objectList[i];
					var parent:Object3D = objectA3DLink[objectM3D.parent];
					var child:Object3D = objectA3DLink[objectM3D.id];
					if (!parent)
					{
						hierarchy.push(child);
						continue;
					}
					parent.addChild(child);
				}
				
				for (i = 0; i < n; i++) 
				{
					//各Object3DのアニメーションIDを保存しておく
					objectA3D = objects[i];
					
					//SKIN初期化
					if (objectA3D is SkinContainer)
					{
						SkinContainer(objectA3D).collectBones();
					}
				}
			}
			
			//モーションデータ用アニメーション
			if (forMotionData)
			{
				motion = new MotionData();
				for (var key:String in scene.animation)
				{
					var keyAnimation:KeyframeAnimation = toKeyAnimation(scene.animation[key]);
					motion.animation[key] = keyAnimation;
				}
				motion.checkTime();
			}
			
			//キーフレームアニメーション
			/*
			n = keyAnimations.length;
			for (i = 0; i < n; i++) 
			{
				keyAnimations[i].setObject(animatedObjectLink[keyAnimations[i]]);
			}
			*/
			
			//不用データ破棄
			scene = null;
			materialA3DLink = null;
			geometryA3DLink = null;
			geometryM3DLink = null;
			
			var resources:Vector.<Resource> = new Vector.<Resource>;
			
			n = objects.length;
			for (i = 0; i < n; i++) 
			{
				var item:Object3D = objects[i];
				VectorUtil.attachListDiff(resources, item.getResources(false, ExternalTextureResource));
			}
			
			//モデルとリソースがあるなら、ここでアタッチしておく（アップロードまではしない）
			if (_hasModel && resourcePack)
			{
				resourcePack.attachTo(resources, false);
			}
			
			//自動でaddChildする対象が指定されている場合
			if (includeTo)
			{
				n = hierarchy.length;
				for (i = 0; i < n; i++) 
				{
					includeTo.addChild(hierarchy[i]);
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * このパーサーが持つ全キーフレームアニメーションをMotionData化する
		 * @return
		 */
		public function createMotionDataFromKeyframeAnimations():MotionData
		{
			var result:MotionData = new MotionData();
			for each(var animation:KeyframeAnimation in keyAnimations)
			{
				//TODO: マテリアルアニメーションの場合はどうする？
				if (animation.targetList.length == 0) continue;
				var key:String = animation.targetList[0].animationID || animation.targetList[0].name;
				result.animation[key] = animation;
			}
			return result.clone();
		}
		
		/**
		 * 元の名前を連結したアニメーション関連付け用のIDをパース
		 * @return
		 */
		private function parseAnimationID(obj:Object3D):String 
		{
			var list:Array = [];
			var target:Object3D = obj;
			while (target)
			{
				var m3d:M3DObject = getM3DByObject3D(target);
				list.push(m3d.animationID || m3d.name);
				target = target.parent;
			}
			list.reverse();
			return list.join("/");
		}
		
		//--------------------------------------------------------------------------
		//
		//  アニメーション化
		//
		//--------------------------------------------------------------------------
		
		private function toKeyAnimation(data:M3DAnimation):KeyframeAnimation 
		{
			var anm:KeyframeAnimation = new KeyframeAnimation(data.type);
			if (data.material) anm.material = toMaterialNode(data.material);
			if (data.position) anm.position = toCurveNode(data.position);
			if (data.rotation) anm.rotation = toCurveNode(data.rotation);
			if (data.scale) anm.scale = toCurveNode(data.scale);
			if (data.matrix) anm.matrix = toMatrixTrack(data.matrix);
			if (data.defaultMatrix) anm.defaultMatrix = new Matrix3D(data.defaultMatrix);
			anm.defaultRotation = data.defaultRotation? data.defaultRotation.clone() : null;
			return anm;
		}
		
		private function toMatrixTrack(matrix:M3DMatrixTrack):AnimationMatrixTrack 
		{
			var result:AnimationMatrixTrack = new AnimationMatrixTrack();
			result.startTime = matrix.startTime;
			result.endTime = matrix.endTime;
			result.loop = matrix.loop;
			var n:int = matrix.timeList.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.addKey(matrix.timeList[i], new Matrix3D(matrix.matrixList[i]), matrix.tangentList[i]);
			}
			return result;
		}
		
		private function toMaterialNode(data:M3DTrackUV):AnimationMaterialNode 
		{
			var node:AnimationMaterialNode = new AnimationMaterialNode();
			if (data.offsetU) node.offsetU = toCurveTrack(data.offsetU);
			if (data.offsetV) node.offsetV = toCurveTrack(data.offsetV);
			return node;
		}
		
		private function toCurveNode(data:M3DTrackXYZ):AnimationCurveNode 
		{
			var node:AnimationCurveNode = new AnimationCurveNode();
			if (data.x) node.x = toCurveTrack(data.x);
			if (data.y) node.y = toCurveTrack(data.y);
			if (data.z) node.z = toCurveTrack(data.z);
			return node;
		}
		
		private function toCurveTrack(data:M3DCurveTrack):AnimationCurveTrack 
		{
			var track:AnimationCurveTrack = new AnimationCurveTrack();
			track.rawData = data;
			track.startTime = data.startTime;
			track.endTime = data.endTime;
			var curveList:Vector.<CurveKey> = new Vector.<CurveKey>;
			
			var n:int = data.keyList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var keyFrame:M3DKeyframe = data.keyList[i];
				var key:CurveKey = new CurveKey();
				key.time = keyFrame.time;
				key.value = keyFrame.value;
				key.tangent = keyFrame.tangent;
				key.prevCtrlTime = keyFrame.prevTime;
				key.nextCtrlTime = keyFrame.nextTime;
				key.prevCtrlValue = keyFrame.prevValue;
				key.nextCtrlValue = keyFrame.nextValue;
				curveList.push(key);
			}
			track.parse(curveList, bezierCurveInterval);
			track.loop = data.loop;
			return track;
		}
		
		//--------------------------------------------------------------------------
		//
		//  オブジェクト化
		//
		//--------------------------------------------------------------------------
		
		private function toObject3D(m3d:M3DObject):Object3D 
		{
			var result:Object3D;
			switch(true)
			{
				///case m3d is M3DBillboard: result = toSprite3D(m3d as M3DBillboard); break;
				case m3d is M3DCamera: result = toCamera(m3d as M3DCamera); break;
				case m3d is M3DMesh: result = toMesh(m3d as M3DMesh); break;
				case m3d is M3DBone: result = toBone(m3d as M3DBone); break;
				case m3d is M3DLight: result = toLight(m3d as M3DLight); break;
				case m3d is M3DLine: result = toLine(m3d as M3DLine); break;
				case m3d is M3DSkinContainer: result = toSkinContainer(m3d as M3DSkinContainer); break;
				default: result = new Object3D();
			}
			if (result == null)
			{
				return null;
			}
			
			result.visible = m3d.visible;
			result.userData = m3d.userData;
			result.name = m3d.name;
			result.animationID = m3d.animationID;
			result.matrix = new Matrix3D(m3d.matrix);
			
			if (result is Mesh)
			{
				Mesh(result).zbias = result.userData.zbias || 0;
			}
			return result;
		}
		
		private function toLine(m3d:M3DLine):Line3D 
		{
			var line:Line3D = new Line3D();
			var geomM3D:M3DGeometry = geometryM3DLink[m3d.geometryID];
			line.geometry = geometryA3DLink[geomM3D.id];
			return line;
		}
		
		private function toCamera(m3d:M3DCamera):Camera3D 
		{
			var camera:Camera3D = new Camera3D();
			camera.fovX = m3d.fovX;
			camera.fovY = m3d.fovY;
			camera.width = m3d.width;
			camera.height = m3d.height;
			if (isNaN(m3d.zNear) == false) camera.zNear = m3d.zNear;
			if (isNaN(m3d.zFar) == false) camera.zFar = m3d.zFar;
			
			return camera;
		}
		
		private function toSkinContainer(m3d:M3DSkinContainer):SkinContainer
		{
			var result:SkinContainer = new SkinContainer();
			return result;
		}
		
		private function toBone(m3d:M3DBone):Bone
		{
			var result:Bone = new Bone();
			result.initialMatrix.rawData = m3d.transformLink;
			result.hasWeight = m3d.enabled;
			result.index = m3d.index;
			return result;
		}
		
		private function toLight(m3d:M3DLight):Light3D
		{
			var light:Light3D;
			switch(m3d.type)
			{
				case M3DLight.AMBIENT: light = new AmbientLight(m3d.color, 1); break;
				case M3DLight.DIRECTIONAL: light = new DirectionalLight(m3d.color, 1); break;
				//case M3DLight.OMNI: light = new OmniLight(m3d.color, m3d.fadeStart, m3d.fadeEnd); break;
				//case M3DLight.SPOT: light = new SpotLight(m3d.color, m3d.fadeStart, m3d.fadeEnd, m3d.innerAngle, m3d.outerAngle); break;
			}
			if (light)
			{
				light.setColor(m3d.color);
				light.intensity = isNaN(m3d.intensity)? 1 : m3d.intensity;
			}
			
			return light;
		}
		
		private function toCombinedGeometry(m3d:M3DCombinedGeometry):CombinedGeometry
		{
			var combined:CombinedGeometry = new CombinedGeometry();
			var idList:Vector.<int> = m3d.geometryIDList;
			
			var n:int = idList.length;
			for (var i:int = 0; i < n; i++) 
			{
				combined.geometries.push(geometryA3DLink[idList[i]]);
			}
			return combined;
		}
		
		private function toGeometry(m3d:M3DMeshGeometry):Geometry 
		{
			if (m3d == null)
			{
				return new Geometry();
			}
			
			var geom:Geometry;
			
			if (m3d is M3DLineGeometry)
			{
				var m3dLineGeom:M3DLineGeometry = m3d as M3DLineGeometry;
				var lineGeom:LineGeometry = new LineGeometry();
				var n:int = m3dLineGeom.segmentList.length;
				for (var i:int = 0; i < n; i++) 
				{
					var m3dSegment:M3DLineSegment = m3dLineGeom.segmentList[i];
					var segment:LineSegment = lineGeom.addSegment();
					var m:int = m3dSegment.pointList.length;
					for (var j:int = 0; j < m; j++) 
					{
						var v:Vector3D = m3dSegment.pointList[j];
						segment.addPoint(v.x, v.y, v.z);
					}
				}
				return lineGeom;
			}
			
			if (m3d is M3DSkinGeometry)
			{
				var m3dSkinGeom:M3DSkinGeometry = m3d as M3DSkinGeometry;
				var skinGeom:SkinGeometry = new SkinGeometry();
				if (m3dSkinGeom.boneIndices1)	skinGeom.addVertices(VertexAttribute.BONEINDEX1, 4, m3dSkinGeom.boneIndices1);
				if (m3dSkinGeom.boneIndices2)	skinGeom.addVertices(VertexAttribute.BONEINDEX2, 4, m3dSkinGeom.boneIndices2);
				if (m3dSkinGeom.weights1)		skinGeom.addVertices(VertexAttribute.BONEWEIGHT1, 4, m3dSkinGeom.weights1);
				if (m3dSkinGeom.weights2)		skinGeom.addVertices(VertexAttribute.BONEWEIGHT2, 4, m3dSkinGeom.weights2);
				
				skinGeom.boneIDList = m3dSkinGeom.boneIDList;
				if (skinGeom.boneIDList == null)
				{
					dispatchError("スキンメッシュ用ジオメトリにboneIDListが存在しません！古いデータの可能性があります。");
					return null;
				}
				if (m3dSkinGeom.boneIndices1 == null)
				{
					dispatchError("スキンメッシュ用ジオメトリにboneIndices1が存在しません！古いデータの可能性があります。");
					return null;
				}
				geom = skinGeom;
			}
			else
			{
				geom = new Geometry();
			}
			
			if (m3d.vertices)		geom.addVertices(VertexAttribute.POSITION, 3, m3d.vertices);
			if (m3d.uvs)			geom.addVertices(VertexAttribute.UV, 2, m3d.uvs);
			if (m3d.normals)		geom.addVertices(VertexAttribute.NORMAL, 3, m3d.normals);
			if (m3d.colors)			geom.addVertices(VertexAttribute.VERTEXCOLOR, 4, m3d.colors);
			if (m3d.tangents)		geom.addVertices(VertexAttribute.TANGENT4, 4, m3d.tangents);
			
			geom.vertexIndices = m3d.vertexIndices;
			
			return geom;
		}
		
		/**
		 * エラーイベントを発行する
		 * @param	text
		 */
		private function dispatchError(text:String):void 
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, text));
		}
		
		private function toMesh(m3d:M3DMesh):Mesh 
		{
			var geomM3D:M3DGeometry = geometryM3DLink[m3d.geometryID];
			var geom:Geometry = geometryA3DLink[geomM3D.id];
			var m3dSkin:M3DSkin = m3d as M3DSkin;
			var mesh:Mesh = m3dSkin? new Skin() : new Mesh();
			mesh.geometry = geom;
			
			if (m3dSkin && !(geom is SkinGeometry) && !(geom is CombinedGeometry))
			{
				dispatchError("スキンメッシュ用ジオメトリの構成に問題があります！古いデータの可能性があります。");
				return null;
			}
			//___スキンの場合、各頂点のボーンインデックス＆ウェイトを設定・・・してたけど、ジオメトリ側で設定しないとだめ？
			/*
			if (mesh is Skin)
			{
				geom.addVertices(VertexAttribute.BONEINDEX, 4, m3dSkin.indexList);
				geom.addVertices(VertexAttribute.BONEWEIGHT, 4, m3dSkin.weightList);
			}
			*/
			var n:int = m3d.surfaceList.length;
			for (var i:int = 0; i < n; i++)
			{
				var sf:M3DSurface = m3d.surfaceList[i];
				var mt:Material = materialA3DLink[sf.material];
				var surface:Surface = new Surface(mt, sf.indexBegin, sf.numTriangle);
				surface.layer = sf.hasTransparentVertex? RenderLayer.TRANSPARENT : RenderLayer.OPAQUE;
				mesh.surfaces.push(surface);
			}
			//ジオメトリが集合体だった場合のサーフェイスリスト
			if (m3d.surfacesList)
			{
				mesh.combinedSurfacesList = new Vector.<Vector.<Surface>>;
				
				n = m3d.surfacesList.length;
				for (i = 0; i < n; i++)
				{
					var surfaces:Vector.<Surface> = new Vector.<Surface>;
					mesh.combinedSurfacesList.push(surfaces);
					var m:int = m3d.surfacesList[i].length;
					for (var j:int = 0; j < m; j++) 
					{
						var sf2:M3DSurface = m3d.surfacesList[i][j];
						var mt2:Material = materialA3DLink[sf2.material];
						var surface2:Surface = new Surface(mt2, sf2.indexBegin, sf2.numTriangle);
						surfaces.push(surface2);
					}
				}
			}
			return mesh;
		}
		
		//--------------------------------------------------------------------------
		//
		//  クラスエイリアス登録
		//
		//--------------------------------------------------------------------------
		
		static public function registClasses():void
		{
			ClassAliasUtil.register(M3DInfo);
			ClassAliasUtil.register(int);
			ClassAliasUtil.register(uint);
			ClassAliasUtil.register(Number);
			ClassAliasUtil.register(Vector3D);
			ClassAliasUtil.register(M3DBone);
			ClassAliasUtil.register(M3DAnimation);
			ClassAliasUtil.register(M3DTrackUV);
			ClassAliasUtil.register(M3DTrackXYZ);
			ClassAliasUtil.register(M3DCurveTrack);
			ClassAliasUtil.register(M3DMatrixTrack);
			ClassAliasUtil.register(M3DKeyframe);
			ClassAliasUtil.register(M3DScene);
			ClassAliasUtil.register(M3DGeometry);
			ClassAliasUtil.register(M3DCombinedGeometry);
			ClassAliasUtil.register(M3DSkinGeometry);
			ClassAliasUtil.register(M3DMeshGeometry);
			ClassAliasUtil.register(M3DLineGeometry);
			ClassAliasUtil.register(M3DLineSegment);
			ClassAliasUtil.register(M3DObject);
			ClassAliasUtil.register(M3DMesh);
			ClassAliasUtil.register(M3DSkin);
			ClassAliasUtil.register(M3DSkinContainer);
			ClassAliasUtil.register(M3DBillboard);
			ClassAliasUtil.register(M3DLine);
			ClassAliasUtil.register(M3DLight);
			ClassAliasUtil.register(M3DMaterial);
			ClassAliasUtil.register(M3DSurface);
			ClassAliasUtil.register(M3DCamera);
			ClassAliasUtil.register(Vector.<int>);
			ClassAliasUtil.register(Vector.<uint>);
			ClassAliasUtil.register(Vector.<Number>);
			ClassAliasUtil.register(Vector.<M3DObject>);
			ClassAliasUtil.register(Vector.<M3DMaterial>);
			ClassAliasUtil.register(Vector.<M3DGeometry>);
			ClassAliasUtil.register(Vector.<M3DSurface>);
			ClassAliasUtil.register(Vector.<M3DLineSegment>);
			ClassAliasUtil.register(Vector.<M3DKeyframe>);
			ClassAliasUtil.register(Vector.<Vector3D>);
		}
		
		public function upload(context3D:ContextProxy, async:Boolean):void 
		{
			var n:int = objects.length;
			for (var i:int = 0; i < n; i++) 
			{
				objects[i].upload(context3D, false, async);
			}
		}
		
		public function getResources():Vector.<Resource> 
		{
			var result:Vector.<Resource> = new Vector.<Resource>;
			var n:int = objects.length;
			for (var i:int = 0; i < n; i++) 
			{
				VectorUtil.attachListDiff(result, objects[i].getResources(false));
			}
			return result;
		}
		
		/**
		 * モデルデータが書き出されているか
		 */
		public function get hasModel():Boolean 
		{
			return _hasModel;
		}
		
		/*
		public function drawAnimation(graphics:Graphics, thickness:Number, scaleX:Number, scaleY:Number):void 
		{
			for each(var key:KeyframeAnimation in keyAnimations)
			{
				if (key.position)
				{
					if (key.position.x) key.position.x.drawAnimation(graphics, thickness, 0xFF0000, scaleX, scaleY);
					if (key.position.y) key.position.y.drawAnimation(graphics, thickness, 0x00FF00, scaleX, scaleY);
					if (key.position.z) key.position.z.drawAnimation(graphics, thickness, 0x0000FF, scaleX, scaleY);
				}
			}
		}
		*/
		
	}

}