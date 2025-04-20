import React from 'react';
import { StyleSheet, TouchableOpacity } from 'react-native';
import { Marker } from 'react-native-maps';
import { Text, View } from 'tamagui';
import { PostWithUser } from '@lib/types';
import { colors } from '../../tamagui.config';

interface MapMarkerProps {
  post: PostWithUser;
  onPress: (post: PostWithUser) => void;
  clusterId?: string;
  clusterCount?: number;
}

export const MapMarker: React.FC<MapMarkerProps> = ({
  post,
  onPress,
  clusterId,
  clusterCount,
}) => {
  // If this is a cluster marker
  if (clusterId && clusterCount) {
    return (
      <Marker
        coordinate={{
          latitude: post.geom?.coordinates[1] || 0,
          longitude: post.geom?.coordinates[0] || 0,
        }}
        onPress={() => onPress(post)}
        tracksViewChanges={false}
      >
        <TouchableOpacity
          onPress={() => onPress(post)}
          style={[styles.clusterMarker, { backgroundColor: colors.primary }]}
        >
          <Text color="white" fontWeight="bold">
            {clusterCount}
          </Text>
        </TouchableOpacity>
      </Marker>
    );
  }

  // Get marker color based on post type
  const getMarkerColor = () => {
    switch (post.type) {
      case 'skillshare':
        return '#9C27B0'; // Purple for skillshare
      case 'task':
        return '#2196F3'; // Blue for task
      case 'interest':
        return '#FF9800'; // Orange for interest
      default:
        return colors.primary;
    }
  };

  // Determine marker style - different for offer and request
  const markerStyle = post.mode === 'offer' ? styles.offerMarker : styles.requestMarker;
  const markerColor = getMarkerColor();

  return (
    <Marker
      coordinate={{
        latitude: post.geom?.coordinates[1] || 0,
        longitude: post.geom?.coordinates[0] || 0,
      }}
      onPress={() => onPress(post)}
      tracksViewChanges={false}
    >
      <TouchableOpacity
        onPress={() => onPress(post)}
        style={[markerStyle, { backgroundColor: markerColor }]}
      >
        <Text color="white" fontWeight="bold" fontSize={post.mode === 'offer' ? 14 : 12}>
          {post.karma_value}
        </Text>
      </TouchableOpacity>
      <View style={styles.triangle} backgroundColor={markerColor} />
    </Marker>
  );
};

const styles = StyleSheet.create({
  offerMarker: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'white',
  },
  requestMarker: {
    width: 36,
    height: 36,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'white',
  },
  clusterMarker: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'white',
  },
  triangle: {
    width: 0,
    height: 0,
    borderLeftWidth: 8,
    borderRightWidth: 8,
    borderTopWidth: 10,
    borderLeftColor: 'transparent',
    borderRightColor: 'transparent',
    marginTop: -3,
    alignSelf: 'center',
  },
}); 